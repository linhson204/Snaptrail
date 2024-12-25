const goongService = require('./goong.service');
const cityService = require('./city.service');

const reverseGeocoding = async (req, res) => {
  const { results } = await goongService.reverseGeocoding(req, res);
  const address = results[0].formatted_address;
  const country = 'Việt Nam';
  const { district } = results[0].compound;
  const classify = results[0].types[0];
  const homeNumber =
    results[0].address_components[0].long_name +
    (results[0].address_components[1].long_name !== results[0].compound.commune
      ? `, ${results[0].address_components[1].long_name}`
      : '');
  const { commune } = results[0].compound;
  const { province } = results[0].compound;
  const cities = await cityService.getCities({ userId: req.query.userId, searchText: province });
  let cityId = cities[0] ? cities[0]._id : null;
  if (!cityId) {
    const city = await cityService.createCity({
      userId: req.query.userId,
      createdAt: Date.now(),
      name: province,
      status: 'enabled',
      visitedTime: 1,
      updatedByUser: false,
      isAutomaticAdded: true,
    });
    cityId = city._id;
  }
  const location = {
    address,
    country,
    district,
    classify,
    homeNumber,
    commune,
    province,
    cityId,
  };
  return location;
};

module.exports = {
  reverseGeocoding,
};
