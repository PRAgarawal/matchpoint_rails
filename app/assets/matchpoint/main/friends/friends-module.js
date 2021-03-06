var usersModule = angular.module('UsersModule', ['ngSanitize']);

usersModule.filter("skill", function(){
  return function (skill) {
    switch(skill) {
      case 8:
        return "Pro";
      case 7:
        return "Open";
      case 6:
        return "Elite";
      case 5:
        return "A";
      case 4:
        return "B";
      case 3:
        return "C";
      case 2:
        return "D";
    }
  }
});

usersModule.config(['$routeProvider', '$compileProvider',
  function ($routeProvider, $compileProvider) {
    $routeProvider.
    when('/friends', {
      templateUrl: 'main/friends/friends.html',
      controller: 'FriendsListController as ctrl'
    }).
    when('/most_active', {
      templateUrl: 'main/friends/most_active.html',
      controller: 'MostActiveListController as ctrl'
    });

    $compileProvider
        .aHrefSanitizationWhitelist(/^\s*(https?|ftp|mailto|sms):/);
  }]);

function openUserInfoModal(user, $modal, $scope, resources) {
  $modal.open({
    templateUrl: 'main/friends/user_info_modal.html',
    controller: 'UserInfoModalController as ctrl',
    'size': 'lg',
    'scope': $scope,
    'resources': resources,
    'resolve': {
      'userId': function() {
        return user.id;
      }
    }
  });
}

usersModule.controller('FriendsListController',
    ['$scope', 'resources', '$modal', 'matchpointModals', function ($scope, resources, $modal, matchpointModals) {
      mixPanelEvts.navigateFriends();
      var ctrl = this;

      ctrl.showUserModal = function(user) {
        openUserInfoModal(user, $modal, $scope, resources);
      };

      function getFriendsAndRequests() {
        resources.all('users').getList().then(function (friends) {
          $scope.friends = friends;
        });
        resources.all('users?requests=true').getList().then(function (friendRequests) {
          $scope.friendRequests = friendRequests;
        });
      }
      getFriendsAndRequests();

      ctrl.showAddFriendDialog = function () {
        $modal.open({
          templateUrl: 'main/friends/add_friend_modal.html',
          controller: 'AddFriendModalController as ctrl',
          'size': 'md',
          'scope': $scope,
          'resources': resources
        });
      };
      
      ctrl.removeFriend = function(friend, isRequest) {
        matchpointModals.genericConfirmation(function() {
          resources.one('users/destroy_friendship/' + friend.id).customDELETE()
              .then(function () {
                if (isRequest) {
                  mixPanelEvts.friendRequestReject(friend);
                } else {
                  mixPanelEvts.friendRemove(friend);
                }
                getFriendsAndRequests();
              });
        }, "remove this friend", "Confirm", "Yes");
      };

      ctrl.acceptRequest = function(friend) {
        resources.one('users/accept_friendship/' + friend.id).customPUT()
            .then(function () {
              mixPanelEvts.friendRequestAccept(friend);
              getFriendsAndRequests();
            });
      };

      ctrl.showInviteFriendDialog = function () {
        $modal.open({
          templateUrl: 'main/friends/invite_friend_modal.html',
          controller: 'InviteFriendModalController as ctrl',
          'size': 'md',
          'scope': $scope,
          'resources': resources
        });
      };
    }]);

usersModule.controller('MostActiveListController',
    ['$scope', 'resources', '$modal', function ($scope, resources, $modal) {
      var ctrl = this;
      mixPanelEvts.navigateMostActive();

      resources.all('users/most_active').getList().then(function (activeUsers) {
        $scope.activeUsers = activeUsers;
      });

      ctrl.showUserModal = function(user) {
        openUserInfoModal(user, $modal, $scope, resources);
      };
  }]);

usersModule.controller('InviteFriendModalController',
    ['$scope', '$modalInstance', 'resources', 'matchpointModals', function ($scope, $modalInstance, resources, matchpointModals) {
      mixPanelEvts.navigateInvite();

      var ctrl = this;
      $scope.data = {};
      $scope.inviteUrl = EXTERNAL_URL + '/users/sign_up?invited_by_code=' + $scope.user.invite_code;
      var smsBody = 'I just joined Match Point to make it easier for us to schedule racquetball matches. Use this link to sign up and become my friend: ' + $scope.inviteUrl;
      var bodyParamChar = getMobileOperatingSystem() === 'iOS' ? '&' : '?';
      $scope.smsInviteLink = bodyParamChar + 'body=' + encodeURIComponent(smsBody);
      
      ctrl.inviteFriend = function () {
        resources.one('users/invite_friend/' + $scope.data.email).customPOST()
            .then(function () {
              mixPanelEvts.emailInvite($scope.data.email);
              $modalInstance.dismiss('cancel');
              matchpointModals.genericConfirmation(null, "Invite sent! You will be notified when this person signs up.", "Success", "OK", true)
            })
      };

      ctrl.isOnMobile = function() { return getMobileOperatingSystem() };
      
      ctrl.cancel = function() { $modalInstance.dismiss('cancel'); }
    }]);

usersModule.controller('AddFriendModalController',
    ['$scope', '$modalInstance', 'resources', 'matchpointModals', function ($scope, $modalInstance, resources, matchpointModals) {
      var ctrl = this;
      $scope.data = {};

      ctrl.addFriend = function () {
        resources.one('users/add_friend/' + $scope.data.friendFinder).customPOST()
            .then(function () {
              mixPanelEvts.addFriend($scope.data.friendFinder);
              $modalInstance.dismiss('cancel');
              matchpointModals.genericConfirmation(null, "Friend request sent! You will be notified when the friend request is accepted.", "Success", "OK", true);
            });
      };

      ctrl.cancel = function() { $modalInstance.dismiss('cancel'); }
    }]);

usersModule.controller('UserInfoModalController',
    ['$scope', '$modalInstance', 'resources', 'userId', '$modal', function ($scope, $modalInstance, resources, userId, $modal) {
      mixPanelEvts.navigateUserProfile();
      var ctrl = this;

      resources.one('users/' + userId).get().then(function (user) {
        $scope.otherUser = user;
      });

      ctrl.addFriend = function() {
        resources.one('users/add_friend/' + userId).customPOST().then(function () {
          mixPanelEvts.addFriend($scope.otherUser);
          $scope.otherUser.friend_status = 'request_sent';
        });
      };

      ctrl.acceptFriend = function() {
        resources.one('users/accept_friendship/' + userId).customPUT().then(function () {
          mixPanelEvts.friendRequestAccept($scope.otherUser);
          $scope.otherUser.friend_status = 'friend';
        });
      };

      ctrl.rejectFriend = function() {
        resources.one('users/accept_friendship/' + userId).customPUT().then(function () {
          mixPanelEvts.friendRequestReject($scope.otherUser);
          $scope.otherUser.friend_status = 'no_friendship';
        });
      };

      ctrl.showUserModal = function(friend) {
        $modalInstance.close('cancel');
        openUserInfoModal(friend, $modal, $scope, resources);
      };

      ctrl.cancel = function() { $modalInstance.close('cancel'); }
    }]);