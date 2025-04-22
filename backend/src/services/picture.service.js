const httpStatus = require('http-status');
const { Picture } = require('../models'); // Đường dẫn tới file chứa model Picture
const { uploadPicture } = require('../middlewares/upload');

/**
 * Create a user
 * @param {Object} pictureBody
 * @returns {Promise<Picture>}
 */
const createPicture = async (req, res) => {
  uploadPicture(req, res, async (err) => {
    if (err) {
      return res.status(httpStatus.BAD_REQUEST).send({ message: err.message });
    }
    if (!req.files) {
      return res.status(httpStatus.BAD_REQUEST).send({ message: 'No file uploaded' });
    }

    try {
      const { userId, capturedAt } = req.body;

      const pictures = await Promise.all(
        req.files.map((file) => {
          const filePath = file.path;
          const picture = Picture.create({
            userId,
            link: filePath,
            capturedAt,
            public_id: file.filename,
          });
          return picture;
        })
      );
      return res.status(httpStatus.OK).send(pictures);
    } catch (error) {
      return res.status(httpStatus.INTERNAL_SERVER_ERROR).send({ message: 'Server Error' });
    }
  });
};

module.exports = {
  createPicture,
};
