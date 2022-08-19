const { splitEvery } = require('ramda');

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

exports.getBatchesParams = getBatchesParams;
