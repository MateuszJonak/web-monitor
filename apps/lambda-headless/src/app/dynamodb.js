const { splitEvery } = require('ramda');
const AWSXRay = require('aws-xray-sdk-core');
const AWS = AWSXRay.captureAWS(require('aws-sdk'));

const docClient = new AWS.DynamoDB.DocumentClient();

const getParams = ({ item }) => ({
  PutRequest: {
    Item: item,
  },
});

const getBatchesParams = (results) => {
  // 25 it's max of items that we can put to DynamoDB in bulk
  const resultsSplitted = splitEvery(25, results);

  return resultsSplitted.map((results) => {
    const putRequestsParams = results.map((r) => getParams({ item: r }));
    const params = {
      RequestItems: {
        [process.env.DATA_TABLE_NAME]: putRequestsParams,
      },
    };
    return params;
  });
};

const writeOffers = async (results) => {
  const batchesParams = getBatchesParams(results);

  const dynamoDBPromises = batchesParams.map((p) =>
    docClient.batchWrite(p).promise()
  );

  const result = await Promise.all(dynamoDBPromises);

  return result;
};

exports.writeOffers = writeOffers;
