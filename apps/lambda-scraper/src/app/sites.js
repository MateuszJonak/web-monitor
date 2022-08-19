const { crawlerQueuePromise } = require('./crawler');
const { parserConfig } = require('./parser');

const parseSites = (event) => {
  const { Records } = event;
  const sites = Records.map((r) => r.dynamodb.NewImage);
  const groupedByType = sites.reduce((result, s) => {
    const typeName = s.type.S;
    if (!result[typeName]) {
      result[typeName] = [];
    }
    result[typeName].push(s);
    return result;
  }, {});

  console.info('Records grouped by type:', JSON.stringify(groupedByType));

  const promises = Object.keys(groupedByType)
    .map((type) => {
      return groupedByType[type].map((siteConfig) => {
        return crawlerQueuePromise({
          uri: siteConfig.url.S,
          parser: parserConfig[type],
        });
      });
    })
    .flat();

  return promises;
};

exports.parseSites = parseSites;
