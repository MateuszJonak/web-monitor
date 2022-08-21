const getSitesConfig = (event) => {
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

  return groupedByType;
};

exports.getSitesConfig = getSitesConfig;
