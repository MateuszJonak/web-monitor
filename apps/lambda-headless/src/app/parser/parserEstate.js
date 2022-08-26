const { nanoid } = require('nanoid');

const listElement = 'div[role="main"] > [data-cy="search.listing"] > ul > li';
const listElementLink = 'a';
const listElementImage = 'a > aside > picture > img';
const listElementTitle = 'a > article h3[data-cy="listing-item-title"]';
const listElementAddress = 'a > article > p';
const listElementPrice = 'a > article > div > span:nth-child(1)';
const listElementPerMeter = 'a > article > div > span:nth-child(2)';
const listElementRoomCount = 'a > article > div > span:nth-child(3)';
const listElementArea = 'a > article > div > span:nth-child(4)';

const parserEstate = async ({ browser, url, category }) => {
  const page = await browser.newPage();

  await page.goto(url);

  await page.waitForSelector(listElement);

  const result = await page.$$eval(listElement, (offers) => {
    return offers.map((offer) => {
      const href = offer.querySelector(listElementLink)?.getAttribute('href');
      const link = href ? window.location.origin + href : undefined;
      return {
        createdAt: new Date().toISOString(),
        link,
        title: offer.querySelector(listElementTitle)?.textContent,
        imageSource: offer.querySelector(listElementImage)?.getAttribute('src'),
        address: offer.querySelector(listElementAddress)?.textContent,
        price: offer.querySelector(listElementPrice)?.textContent,
        perMeter: offer.querySelector(listElementPerMeter)?.textContent,
        roomCount: offer.querySelector(listElementRoomCount)?.textContent,
        area: offer.querySelector(listElementArea)?.textContent,
        readed: false,
      };
    });
  });

  await page.close();

  return result
    .filter((o) => !!o.link)
    .map((o) => ({ ...o, id: nanoid(), category }));
};

exports.parserEstate = parserEstate;
