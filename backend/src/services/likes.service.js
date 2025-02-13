const likesModel = require('../models/likes.model');

const addLike = async (likeBody) => {
  const like = likesModel.create(likeBody);
  return like;
};

const getLikeById = async (likeId) => {
  return likesModel.findById(likeId);
};

const removeLike = async (likeId) => {
  const like = await getLikeById(likeId);
  if (!like) {
    throw new Error('Like not found');
  }
  await like.remove();
  return like;
};

const getLikesByPostId = async (postId) => {
  const likes = await likesModel.find({ postId });
  return likes;
};

module.exports = {
  addLike,
  getLikeById,
  removeLike,
  getLikesByPostId,
};
