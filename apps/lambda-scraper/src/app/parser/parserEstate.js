const { nanoid } = require('nanoid');

const listElementLink = 'a';
const listElementTitle = 'a > article h3[data-cy="listing-item-title"]';
const listElementAddress = 'a > article > p';
const listElementPrice = 'a > article > div > span:nth-child(1)';
const listElementPerMeter = 'a > article > div > span:nth-child(2)';
const listElementRoomCount = 'a > article > div > span:nth-child(3)';
const listElementArea = 'a > article > div > span:nth-child(4)';

const parserEstate = (res) => {
  const $ = res.$;
  const data = [];
  $('div[role="main"] > [data-cy="search.listing"] > ul > li').each(
    function () {
      const offer = {
        id: nanoid(),
        createdAt: new Date().toISOString(),
        link: $(this).find(listElementLink).attr('href'),
        title: $(this).find(listElementTitle).text(),
        address: $(this).find(listElementAddress).text(),
        price: $(this).find(listElementPrice).text(),
        perMeter: $(this).find(listElementPerMeter).text(),
        roomCount: $(this).find(listElementRoomCount).text(),
        area: $(this).find(listElementArea).text(),
        readed: false,
      };
      data.push(offer);
    }
  );
  return data;
};

exports.parserEstate = parserEstate;
