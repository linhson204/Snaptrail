const express = require('express');
const pictureController = require('../../controllers/picture.controller');

const router = express.Router();

router.route('/').post(pictureController.createPicture);

module.exports = router;

/**
 * @swagger
 * tags:
 *   name: Pictures
 *   description: Picture management and retrieval
 */

/**
 * @swagger
 * /pictures:
 *   post:
 *     summary: Create some pictures
 *     description: Upload new pictures.
 *     tags: [Pictures]
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - userId
 *               - capturedAt
 *             properties:
 *               userId:
 *                 type: Schema.Types.ObjectId
 *                 description: ID of the user uploading the picture
 *               capturedAt:
 *                 type: number
 *                 description: The date and time when the picture was created
 *               picture:
 *                 type: string
 *                 format: binary
 *                 description: The picture files to upload
 *     responses:
 *       "200":
 *         description: Pictures uploaded successfully
 *         content:
 *           application/json:
 *             schema:
 *                type: array
 *                items:
 *                  $ref: '#/components/schemas/Picture'
 *       "400":
 *         $ref: '#/components/responses/BadRequest'
 *       "500":
 *         $ref: '#/components/responses/InternalError'
 *
 */
