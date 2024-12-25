const Joi = require('joi');
const { objectId } = require('./custom.validation');

const getPictures = {
  query: Joi.object().keys({
    userId: Joi.string(),
    link: Joi.string(),
    capturedAt: Joi.date(),
    public_id: Joi.string(),
  }),
};

module.exports = {
  getPictures,
};
