const chromium = require('@sparticuz/chrome-aws-lambda');
const AWSXRay = require('aws-xray-sdk-core');
const { getSitesConfig } = require('./app/sites');
const { parser } = require('./app/parser');
const { writeOffers } = require('./app/dynamodb');

AWSXRay.captureHTTPsGlobal(require('http'));
AWSXRay.captureHTTPsGlobal(require('https'));

const xRaySegment = AWSXRay.getSegment(); //returns the facade segment

exports.handler = async (event, context, callback) => {
  console.log(`New event: ${JSON.stringify(event)}`);

  const sitesConfig = getSitesConfig(event);

  console.info('sites records:', JSON.stringify(sitesConfig));

  let browser = null;
  let results = null;

  try {
    const xRayBrowserLaunch = xRaySegment.addNewSubsegment('browser launch');
    browser = await chromium.puppeteer.launch({
      args: chromium.args,
      defaultViewport: chromium.defaultViewport,
      executablePath: await chromium.executablePath,
      headless: chromium.headless,
      ignoreHTTPSErrors: true,
    });
    xRayBrowserLaunch.close();

    const xRayParser = xRaySegment.addNewSubsegment('parser');
    results = await parser({ browser, sitesConfig });
    xRayParser.close();

    console.info('Results:', results);

    const xRayDynamoDB = xRaySegment.addNewSubsegment('dynamodb write');
    await writeOffers(results);
    xRayDynamoDB.close();

    console.info('Successfully created items!');
  } catch (error) {
    console.error(error);
    return callback(error);
  } finally {
    if (browser !== null) {
      const xRayBrowserClose = xRaySegment.addNewSubsegment('browser close 2');
      await browser.close();
      xRayBrowserClose.close();

      console.info('Browser closed!');
    }
  }

  return callback(null, results);
};
