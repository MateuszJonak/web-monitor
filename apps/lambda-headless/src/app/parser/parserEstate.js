const { nanoid } = require('nanoid');

const listElementLink = 'a';
const listElementTitle = 'a > article h3[data-cy="listing-item-title"]';
const listElementAddress = 'a > article > p';
const listElementPrice = 'a > article > div > span:nth-child(1)';
const listElementPerMeter = 'a > article > div > span:nth-child(2)';
const listElementRoomCount = 'a > article > div > span:nth-child(3)';
const listElementArea = 'a > article > div > span:nth-child(4)';

const parserEstate = async ({ browser, url, category }) => {
  const page = await browser.newPage();

  await page.goto(url);

  await page.waitForSelector(
    'div[role="main"] > [data-cy="search.listing"] > ul > li'
  );

  const result = await page.$$eval(
    'div[role="main"] > [data-cy="search.listing"] > ul > li',
    (offers) => {
      return offers.map((offer) => {
        return {
          createdAt: new Date().toISOString(),
          link: offer.querySelector(listElementLink)?.getAttribute('href'),
          title: offer.querySelector(listElementTitle)?.textContent,
          address: offer.querySelector(listElementAddress)?.textContent,
          price: offer.querySelector(listElementPrice)?.textContent,
          perMeter: offer.querySelector(listElementPerMeter)?.textContent,
          roomCount: offer.querySelector(listElementRoomCount)?.textContent,
          area: offer.querySelector(listElementArea)?.textContent,
          readed: false,
        };
      });
    }
  );

  await page.close();

  return result
    .filter((o) => !!o.link)
    .map((o) => ({ ...o, id: nanoid(), category }));
};

exports.parserEstate = parserEstate;
