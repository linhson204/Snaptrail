const commentModel = require('../models/comments.model');

const createComment = async (comment) => {
  return await commentModel.create(comment);
};

const getCommentById = async (commentId) => {
  return await commentModel.findById(commentId);
};

const getCommentsByPostId = async (postId) => {
  comments = await commentModel.find({ postId });
  return comments;
};

const updateCommentById = async (commentId, commentBody) => {
  const comment = await getCommentById(commentId);
  if (!comment) {
    throw new Error('Comment not found');
  }
  Object.assign(comment, commentBody);
  return await comment.save();
};

const deleteCommentById = async (commentId) => {
  const comment = await getCommentById(commentId);
  if (!comment) {
    throw new Error('Comment not found');
  }
  await comment.remove();
};

const addFeedbackToComment = async (commentId, feedback) => {
  const comment = await getCommentById(commentId);
  if (!comment) {
    throw new Error('Comment not found');
  }

  // Thêm feedback vào mảng listFeedback
  comment.listFeedback.push({
    ...feedback,
    createdAt: Date.now(),
    updatedAt: Date.now(),
  });

  // Lưu lại comment
  return await comment.save();
};

const updateFeedbackInComment = async (commentId, feedbackId, feedbackBody) => {
  const comment = await getCommentById(commentId);
  if (!comment) {
    throw new Error('Comment not found');
  }

  const feedback = comment.listFeedback.find((fb) => fb._id.toString() === feedbackId);
  if (!feedback) {
    throw new Error('Feedback not found');
  }

  Object.assign(feedback, feedbackBody, { updatedAt: Date.now() });

  // Lưu lại comment
  return await comment.save();
};

const deleteFeedbackFromComment = async (commentId, feedbackId) => {
  const comment = await getCommentById(commentId);
  if (!comment) {
    throw new Error('Comment not found');
  }

  // Xóa feedback khỏi mảng listFeedback
  comment.listFeedback = comment.listFeedback.filter((fb) => fb._id.toString() !== feedbackId);

  // Lưu lại comment
  return await comment.save();
};

module.exports = {
  createComment,
  getCommentById,
  getCommentsByPostId,
  updateCommentById,
  deleteCommentById,
  addFeedbackToComment,
  updateFeedbackInComment,
  deleteFeedbackFromComment,
};
