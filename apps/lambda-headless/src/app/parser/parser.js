const { parserEstate } = require('./parserEstate');

const parserConfig = {
  estate: parserEstate,
};

const parser = async ({ browser, sitesConfig }) => {
  const promises = Object.keys(sitesConfig)
    .map((type) => {
      const parserSite = parserConfig[type];

      return sitesConfig[type].map((siteConfig) => {
        return parserSite({
          browser,
          url: siteConfig.url.S,
          category: siteConfig.category.S,
        });
      });
    })
    .flat();

  const results = await Promise.all(promises);

  return results.flat();
};

exports.parser = parser;
