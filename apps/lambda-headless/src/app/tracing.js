const AWSXRay = require('aws-xray-sdk-core');

const xRaySegment = AWSXRay.getSegment(); //returns the facade segment

const withPromiseTracing = async ({ callback, name }) => {
  const xRayParser = xRaySegment.addNewSubsegment(name);
  const result = await callback();
  xRayParser.close();

  return result;
};

exports.withPromiseTracing = withPromiseTracing;
