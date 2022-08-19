const { nanoid } = require('nanoid');
const AWS = require('aws-sdk');
const docClient = new AWS.DynamoDB.DocumentClient();
const s3 = new AWS.S3({ apiVersion: '2006-03-01' });

const getParams = ({ url, type, name }) => ({
  TableName: process.env.PUB_SUB_TABLE_NAME,
  Item: {
    id: nanoid(),
    createdAt: new Date().toISOString(),
    url,
    type,
    name,
  },
});

const getConfig = async () => {
  const response = await s3
    .getObject({
      Bucket: process.env.S3_CONFIG_BUCKET_NAME,
      Key: process.env.S3_CONFIG_KEY,
    })
    .promise();

  const config = response.Body.toString('utf-8');
  return JSON.parse(config);
};

exports.handler = async () => {
  try {
    const config = await getConfig();
    const putParamsArray = config.sites.map((s) => getParams(s));
    const promises = putParamsArray.map((params) =>
      docClient.put(params).promise()
    );
    await Promise.all(promises);
    console.info('Successfully created items!', JSON.stringify(putParamsArray));
    return { body: 'Successfully created items!' };
  } catch (err) {
    console.error(err);
    return { error: err };
  }
};
