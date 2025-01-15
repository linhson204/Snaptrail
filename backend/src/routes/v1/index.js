const express = require('express');
const authRoute = require('./auth.route');
const userRoute = require('./user.route');
const docsRoute = require('./docs.route');
const pictureRoute = require('./picture.route');
const locationRoute = require('./location.route');
const postRoute = require('./post.route');
const likesRoute = require('./likes.route');
const commentsRoute = require('./comments.route');
const goongRoute = require('./goong.route');
const config = require('../../config/config');

const router = express.Router();

const defaultRoutes = [
  {
    path: '/auth',
    route: authRoute,
  },
  {
    path: '/users',
    route: userRoute,
  },
  {
    path: '/pictures',
    route: pictureRoute,
  },
  {
    path: '/location',
    route: locationRoute,
  },
  {
    path: '/posts',
    route: postRoute,
  },
  {
    path: '/posts/likes',
    route: likesRoute,
  },
  {
    path: '/posts/comments',
    route: commentsRoute,
  },
  {
    path: '/goong',
    route: goongRoute,
  },
];

const devRoutes = [
  // routes available only in development mode
  {
    path: '/docs',
    route: docsRoute,
  },
];

defaultRoutes.forEach((route) => {
  router.use(route.path, route.route);
});

/* istanbul ignore next */
if (config.env === 'development') {
  devRoutes.forEach((route) => {
    router.use(route.path, route.route);
  });
}

module.exports = router;
