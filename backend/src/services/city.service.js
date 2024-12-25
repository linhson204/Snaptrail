const httpStatus = require('http-status');
const City = require('../models/city.model');
const ApiError = require('../utils/ApiError');
const Message = require('../utils/Message');

const createCity = async (cityBody) => {
  const existedCity = await City.findOne(cityBody);
  if (existedCity) {
    throw new ApiError(httpStatus.BAD_REQUEST, Message.cityMsg.nameExisted);
  }
  const city = await City.create(cityBody);
  return city;
};

const getCities = async (cityBody) => {
  const { userId, searchText, status = 'enabled' } = cityBody;
  const filter = { userId, status };
  if (searchText) {
    filter.name = { $regex: searchText, $options: 'i' };
  }
  const city = await City.find(filter);
  return city;
};

module.exports = {
  createCity,
  getCities,
};
