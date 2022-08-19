const AWSXRay = require('aws-xray-sdk-core');
const AWS = AWSXRay.captureAWS(require('aws-sdk'));
const { parseSites } = require('./app/sites');
const { getBatchesParams } = require('./app/dynamodb');

AWSXRay.captureHTTPsGlobal(require('http'));
AWSXRay.captureHTTPsGlobal(require('https'));

const docClient = new AWS.DynamoDB.DocumentClient();
const xRaySegment = AWSXRay.getSegment(); //returns the facade segment

exports.handler = async (event) => {
  console.log(`EVENT: ${JSON.stringify(event)}`);

  try {
    const parsedSitesPromises = parseSites(event);

    const xRayCrawlerSubsegment = xRaySegment.addNewSubsegment('crawler');
    const results = await Promise.all(parsedSitesPromises);
    xRayCrawlerSubsegment.close();

    const resultsFlattened = results.flat();

    console.info('Results from website:', JSON.stringify(resultsFlattened));

    const batchesParams = getBatchesParams(resultsFlattened);

    const dynamoDBPromises = batchesParams.map((p) =>
      docClient.batchWrite(p).promise()
    );

    await Promise.all(dynamoDBPromises);

    console.info('Successfully created items!', JSON.stringify(batchesParams));

    return {
      statusCode: 200,
      body: batchesParams,
      length: batchesParams.length,
    };
  } catch (err) {
    console.error(err);
    return { error: err };
  }
};
