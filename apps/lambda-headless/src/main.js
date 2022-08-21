const chromium = require('@sparticuz/chrome-aws-lambda');
const AWSXRay = require('aws-xray-sdk-core');
const { getSitesConfig } = require('./app/sites');
const { parser } = require('./app/parser');
const { writeOffers } = require('./app/dynamodb');
const { withPromiseTracing } = require('./app/tracing');

const xRaySegment = AWSXRay.getSegment(); //returns the facade segment

exports.handler = async (event, context, callback) => {
  console.log(`New event: ${JSON.stringify(event)}`);

  const sitesConfig = getSitesConfig(event);

  console.info('sites records:', JSON.stringify(sitesConfig));

  let browser = null;
  let offers = null;

  try {
    const xRayBrowserLaunch = xRaySegment.addNewSubsegment('Browser launch');
    browser = await chromium.puppeteer.launch({
      args: chromium.args,
      defaultViewport: chromium.defaultViewport,
      executablePath: await chromium.executablePath,
      headless: chromium.headless,
      ignoreHTTPSErrors: true,
    });
    xRayBrowserLaunch.close();

    offers = await withPromiseTracing({
      callback: () => parser({ browser, sitesConfig }),
      name: 'parser',
    });

    console.info('Offers:', offers);

    await Promise.all([
      await withPromiseTracing({
        callback: () =>
          writeOffers(offers).then((results) => {
            console.info('Successfully created items!');
            return results;
          }),
        name: 'Dynamodb write',
      }),
      await withPromiseTracing({
        callback: () =>
          browser.close().catch((error) => {
            console.info(
              'First attempt of browser.close() ended with an error:',
              error
            );
          }),
        name: 'Browser close',
      }),
    ]);
  } catch (error) {
    console.error(error);
    return callback(error);
  } finally {
    if (browser !== null) {
      await withPromiseTracing({
        callback: () => browser.close(),
        name: 'Finally Browser close',
      });

      console.info('Browser closed!');
    }
  }

  return callback(null, offers);
};
