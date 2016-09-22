var friendsModule = angular.module('FriendsModule', ['ngSanitize']);

friendsModule.config(['$routeProvider',
  function ($routeProvider) {
    $routeProvider.
    when('/friends', {
      templateUrl: 'main/friends/friends.html',
      controller: 'FriendsListController as ctrl'
    })
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

friendsModule.controller('FriendsListController',
    ['$scope', 'resources', '$modal', 'matchpointModals', function ($scope, resources, $modal, matchpointModals) {
      var ctrl = this;

      function getFriendsAndRequests() {
        resources.all('users').getList().then(function (friends) {
          $scope.friends = friends;
        });
        resources.all('users?requests=true').getList().then(function (friendRequests) {
          $scope.friendRequests = friendRequests;
        });
      }
      getFriendsAndRequests();

      ctrl.showInviteFriendDialog = function () {
        $modal.open({
          templateUrl: 'main/friends/invite_friend_modal.html',
          controller: 'InviteFriendModalController as ctrl',
          'size': 'md',
          'scope': $scope,
          'resources': resources
        });
      };

      ctrl.showAddFriendDialog = function () {
        $modal.open({
          templateUrl: 'main/friends/add_friend_modal.html',
          controller: 'AddFriendModalController as ctrl',
          'size': 'md',
          'scope': $scope,
          'resources': resources
        });
      };
      
      ctrl.removeFriend = function(friendId) {
        matchpointModals.genericConfirmation(function() {
          resources.one('users/destroy_friendship/' + friendId).customDELETE()
              .then(function () {
                getFriendsAndRequests();
              });
        }, "remove this friend", "Confirm", "Yes");
      };

      ctrl.acceptRequest = function(friendId) {
        resources.one('users/accept_friendship/' + friendId).customPUT()
            .then(function () {
              getFriendsAndRequests();
            });
      };
    }]);

friendsModule.controller('InviteFriendModalController',
    ['$scope', '$modalInstance', 'resources', 'matchpointModals', function ($scope, $modalInstance, resources, matchpointModals) {
      var ctrl = this;
      $scope.data = {};
      
      ctrl.inviteFriend = function () {
        resources.one('users/invite_friend/' + $scope.data.email).customPOST()
            .then(function () {
              $modalInstance.dismiss('cancel');
              matchpointModals.genericConfirmation(null, "Invite sent!", "Success", "OK", true)
            })
      };
      
      ctrl.cancel = function() { $modalInstance.dismiss('cancel'); }
    }]);

friendsModule.controller('AddFriendModalController',
    ['$scope', '$modalInstance', 'resources', 'matchpointModals', function ($scope, $modalInstance, resources, matchpointModals) {
      var ctrl = this;
      $scope.data = {};

      ctrl.addFriend = function () {
        resources.one('users/add_friend/' + $scope.data.friendFinder).customPOST()
            .then(function () {
              $modalInstance.dismiss('cancel');
              matchpointModals.genericConfirmation(null, "Friend request sent!", "Success", "OK", true);
            });
      };

      ctrl.cancel = function() { $modalInstance.dismiss('cancel'); }
    }]);

friendsModule.controller('UserInfoModalController',
    ['$scope', '$modalInstance', 'resources', 'userId', function ($scope, $modalInstance, resources, userId) {
      var ctrl = this;

      resources.one('users/' + userId).get().then(function (user) {
        $scope.otherUser = user;
      });

      ctrl.addFriend = function() {
        resources.one('users/add_friend/' + userId).customPOST().then(function () {
          $scope.otherUser.friend_status = 'request_sent';
        });
      };

      ctrl.acceptFriend = function() {
        resources.one('users/accept_friendship/' + userId).customPUT().then(function () {
          $scope.otherUser.friend_status = 'friend';
        });
      };

      ctrl.cancel = function() { $modalInstance.close('cancel'); }
    }]);