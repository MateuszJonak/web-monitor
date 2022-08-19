const Crawler = require('crawler');

const crawler = new Crawler({
  maxConnections: 10,
});

exports.crawler = crawler;

const crawlerQueuePromise = ({ uri, parser }) =>
  new Promise((resolve, reject) => {
    crawler.queue({
      uri: uri,
      callback: (error, res, done) => {
        if (error) {
          done();
          return reject(error);
        }
        if (res.statusCode === 403) {
          done();
          return reject(new Error(res.body));
        }
        const result = parser(res);
        done();
        return resolve(result);
      },
    });
  });

exports.crawlerQueuePromise = crawlerQueuePromise;
