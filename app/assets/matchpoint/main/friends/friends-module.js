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
      mixpanel.track("Navigate 'Friends'");
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
    }]);

friendsModule.controller('InviteFriendModalController',
    ['$scope', '$modalInstance', 'resources', 'matchpointModals', function ($scope, $modalInstance, resources, matchpointModals) {
      var ctrl = this;
      $scope.data = {};
      
      ctrl.inviteFriend = function () {
        resources.one('users/invite_friend/' + $scope.data.email).customPOST()
            .then(function () {
              mixPanelEvts.inviteFriend(scope.data.email);
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
              mixPanelEvts.addFriend($scope.data.friendFinder);
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
          mixPanelEvts.friendRequestAccept($scope.otherUser);
          $scope.otherUser.friend_status = 'friend';
        });
      };

      //TODO: Implement reject friend button
      ctrl.rejectFriend = function() {
        resources.one('users/accept_friendship/' + userId).customPUT().then(function () {
          mixPanelEvts.friendRequestReject($scope.otherUser);
          $scope.otherUser.friend_status = 'no_friendship';
        });
      };

      ctrl.cancel = function() { $modalInstance.close('cancel'); }
    }]);