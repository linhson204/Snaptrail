const registerSuccess = 'Đăng ký thành công';
const loginSuccess = 'Đăng nhập thành công';
const logoutSuccess = 'Đăng xuất thành công';
const deactivatedAccount = 'Tài khoản bị tạm khóa';
const phoneVerify = 'Số điện thoại hoặc mật khẩu không đúng';

const ok = 'ok';
const success = 'Thành công';
const uploaded = 'Đã đăng tải';
const notFound = 'Không tìm thấy';
const deleted = 'Đã xoá';
const updated = 'Đã cập nhật';

const locationMsg = {
  created: 'tạo điểm cố định thành công',
  name: 'không được để trống tên',
  nameExisted: 'điểm cố định này đã tồn tại',
  notFound: 'điểm cố định này không tồn tại',
  deleted: 'Xóa điểm cố định thành công',
  updated: 'Cập nhật location thành công',
};

const cityMsg = {
  created: 'tạo thành phố thành công',
  name: 'không được để trống tên',
  nameExisted: 'thành phố này đã tồn tại',
  notFound: 'thành phố này không tồn tại',
  deleted: 'Xóa thành phố thành công',
  updated: 'Cập nhật thành phố thành công',
};

const pictureMsg = {
  created: 'tạo ảnh thành công ',
  nameExisted: 'ảnh đã tồn tại',
  notFound: 'ảnh không tồn tại',
  deleted: 'Xóa ảnh thăm thành công',
};

const userMsg = {
  notFound: 'Không tồn tại user này',
  emailAlreadyTaken: 'Email này đã được dùng',
  notMatchingCurrentPassword: 'Không thể thay đổi mật khẩu do nhập sai mật khẩu cũ',
  updated: 'Cập nhật user thành công',
  deleted: 'Xóa user thành công',
  invalidOTP: 'Mã OTP không hợp lệ',
  successfullyCreatedOTP: 'Tạo OTP thành công',
  successfullyChangedPassword: 'Đổi password thành công',
  expiredOTP: 'OTP đã hết hạn',
};

const validationMsg = {
  nameRequired: 'Yêu cầu nhập tên',
  startTimeRequire: 'Yêu cầu nhập thời gian bắt đầu',
  endTimeRequire: 'Yêu cầu nhập thời gian kết thúc',
  timeMustBePositiveIntegerNumber: 'Giờ hoặc phút phải là số nguyên dương',
  latitudeRequired: 'Không có thông tin vị trí',
  longtitudeRequired: 'Không có thông tin vị trí',
};

const uploadMsg = {
  exceedFileUploadSize: 'Vượt quá dung lượng upload tối đa',
  invalidFileExtension: 'Định dạng file không hợp lệ',
  failedUpload: 'Upload file thất bại',
  exceedFileUploadSize5MB: 'Vui lòng up ảnh với dung lượng tối đa chỉ được 5Mb',
};

module.exports = {
  registerSuccess,
  loginSuccess,
  logoutSuccess,
  deactivatedAccount,
  phoneVerify,
  ok,
  success,
  deleted,
  updated,
  uploaded,
  notFound,
  pictureMsg,
  userMsg,
  validationMsg,
  uploadMsg,
  locationMsg,
  cityMsg,
};
