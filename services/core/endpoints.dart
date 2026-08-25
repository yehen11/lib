/*
@Author - Anuruddha
@Date - 2025/05/09
 */

class Endpoints {
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const ping = '/ping';
  static const saveUser = '/saveUser';
  static const updateUser = '/updateUser';
  static const getUserByIds = '/getUserbyIDs';

  static const String subscriptions = '/subscriptions';


  static const String setShop = '/setShop';
  static const String updateShop = '/updateShop';
  static const String deleteShop = '/deleteShop';
  static const String getShopsByShopIDs = '/getShopbyShopIDs';
  static const String getShopsByUserID = '/getShopsbyUserID';

  //Shop Media Upload/Download Endpoints
  static const String getShopLogoUploadUrl = '/getShopLogoUploadUrl';
  static const String getShopLogoDownloadUrl = '/getShopLogoDownloadUrl';
  static const String getShopBannerUploadUrl = '/getShopBannerUploadUrl';
  static const String getShopBannerDownloadUrl = '/getShopBannerDownloadUrl';

  //profile
  static const String getProfilePicUploadUrl = '/getProfilePicUploadUrl';
  static const String getProfilePicDownloadUrl = '/getProfilePicDownloadUrl';

  //thumbnail
  static const String getThumbnailUploadUrl = '/getThumbnailUploadUrl';
  static const String getThumbnailDownloadUrl = '/getThumbnailDownloadUrl';

  //video
  static const String getReelVideoUploadUrl = "/getReelVideoUploadUrl";
  static const String saveVideoEntry = "/saveVideoEntry";
  static const String convert = '/convert';

  //video suggestion
  static const String getAllVideos = '/getAllVideos';
  static const String getVideoEntriesByIds = '/getVideoEntriesByIds';
  static const String getVideoEntriesByAuthor = '/getVideoEntriesByAuthor';
  static const String getRecommendationsV1 = '/v1/recommendation';
  static const String getRecommendationsV2 = '/v2/recommendation';

  //cdn
  static const String getCdn = '/cdn/getCdn';
  //subscription

  //Like
  static const String likeVideo = '/likeVideo';
  static const String unlikeVideo = '/unlikeVideo';
  static const String isLiked = '/isLiked';
  static const String getLikeCount = '/getLikeCount';

  static const String helpSupport = '/help';

  

}
