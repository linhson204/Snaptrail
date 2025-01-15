const goongService = require('./goong.service');

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

  const location = {
    address,
    country,
    district,
    classify,
    homeNumber,
    commune,
    province,
  };
  return location;
};

module.exports = {
  reverseGeocoding,
};
