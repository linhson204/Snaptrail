const httpStatus = require('http-status');
const Message = require('../utils/Message');
const catchAsync = require('../utils/catchAsync');
const locationService = require('../services/location.service');

const createLocation = catchAsync(async (req, res) => {
  const requestBody = req.body;
  requestBody.userId = req.params.userId;
  const location = await locationService.createLocation(requestBody);
  res.status(httpStatus.CREATED).send({
    code: httpStatus.CREATED,
    message: Message.locationMsg.created,
    result: location,
  });
});

const getLocation = catchAsync(async (req, res) => {
  const request = req.body;
  request.userId = req.params.userId;
  const location = await locationService.getLocation(request);
  res.send({ code: httpStatus.OK, message: Message.ok, result: location });
});

const reverseGeocoding = catchAsync(async (req, res) => {
  const location = await locationService.reverseGeocoding(req, res);
  // console.log(location);
  res.json(location);
});

const getClosestLocation = catchAsync(async (req, res) => {
  const { lat, lng } = req.query;
  const location = await locationService.getClosestLocation({ lat, lng });
  res.send({ code: httpStatus.OK, message: Message.ok, result: location });
});

module.exports = {
  createLocation,
  getLocation,
  reverseGeocoding,
  getClosestLocation,
};
