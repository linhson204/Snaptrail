const express = require('express');
const locationController = require('../../controllers/location.controller');

const router = express.Router();

router.route('/closest-location').get(locationController.getClosestLocation);

router.route('/reverse-geocoding').get(locationController.reverseGeocoding);
/**
 * @swagger
 * /location/reverse-geocoding:
 *   get:
 *     summary: Reverse geocoding
 *     tags: [Locations]
 *     parameters:
 *       - in: query
 *         name: lat
 *         required: true
 *         schema:
 *           type: number
 *         description: Latitude
 *       - in: query
 *         name: lng
 *         required: true
 *         schema:
 *           type: number
 *         description: Longitude
 *       - in: query
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       "200":
 *         description: OK
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 code:
 *                   type: integer
 *                   example: 200
 *                 message:
 *                   type: string
 *                   example: tự chạy postman mà xem chứ swagger này không đúng đâu =)))
 *                 result:
 *                   type: object
 *                   properties:
 *                     address:
 *                       type: string
 *                       example: "24 Hoa Lu Phuong Le Dai Hanh"
 *                     country:
 *                       type: string
 *                       example: "Viet Nam"
 *                     district:
 *                       type: string
 *                       example: "Hoa Lu"
 *                     city:
 *                       type: string
 *                       example: "Hanoi"
 *       "400":
 *         description: Bad Request
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 code:
 *                   type: integer
 *                   example: 400
 *                 message:
 *                   type: string
 *                   example: Invalid parameters
 */
module.exports = router;
