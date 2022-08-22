const AWSXRay = require('aws-xray-sdk-core');

const withPromiseTracing = async ({ callback, name }) => {
  const xRaySegment = AWSXRay.getSegment();

  const xRayParser = xRaySegment.addNewSubsegment(name);
  const result = await callback();
  xRayParser.close();

  return result;
};

exports.withPromiseTracing = withPromiseTracing;
