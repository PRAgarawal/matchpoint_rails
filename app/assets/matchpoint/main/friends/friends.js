var friendsModule = angular.module('FriendsModule', ['ngSanitize']);

friendsModule.config(['$routeProvider',
  function ($routeProvider) {
    $routeProvider.
    when('/friends_courts', {
      templateUrl: 'main/friends/friends.html',
      controller: 'FriendsListController as ctrl'
    }).
    when('/friends/:id', {
      templateUrl: 'main/friends/friend.html',
      controller: 'ViewFriendController as ctrl'
    });
  }]);

friendsModule.controller('FriendsListController',
    ['$scope', 'resources', function ($scope, resources) {
    }]);

friendsModule.controller('ViewFriendController',
    ['$scope', 'resources', function ($scope, resources) {
    }]);
