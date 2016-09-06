var friendsModule = angular.module('FriendsModule', ['ngSanitize']);

friendsModule.config(['$routeProvider',
  function ($routeProvider) {
    $routeProvider.
    when('/friends', {
      templateUrl: 'main/friends/friends.html',
      controller: 'FriendsListController as ctrl'
    })
  }]);

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
        }).result.then(function () {
          matchpointModals.genericConfirmation(null, "Invite sent!", "Success", "OK", true)
        });
      };

      ctrl.showAddFriendDialog = function () {
        $modal.open({
          templateUrl: 'main/friends/add_friend_modal.html',
          controller: 'AddFriendModalController as ctrl',
          'size': 'md',
          'scope': $scope,
          'resources': resources
        }).result.then(function () {
          matchpointModals.genericConfirmation(null, "Friend request sent!", "Success", "OK", true);
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
    ['$scope', '$modalInstance', 'resources', function ($scope, $modalInstance, resources) {
      var ctrl = this;
      $scope.data = {};
      
      ctrl.inviteFriend = function () {
        resources.one('users/invite_friend/' + $scope.data.email).customPOST()
            .then(function () {
              $modalInstance.dismiss('cancel');
            })
      };
      
      $scope.cancel = function() { $modalInstance.dismiss('cancel'); }
    }]);

friendsModule.controller('AddFriendModalController',
    ['$scope', '$modalInstance', 'resources', function ($scope, $modalInstance, resources) {
      var ctrl = this;
      $scope.data = {};

      ctrl.addFriend = function () {
        resources.one('users/add_friend/' + $scope.data.friendFinder).customPOST()
            .then(function (res, err) {
              console.log(res);
              console.log(err);
              $modalInstance.dismiss('cancel');
            });
      };

      ctrl.cancel = function() { $modalInstance.dismiss('cancel'); }
    }]);
