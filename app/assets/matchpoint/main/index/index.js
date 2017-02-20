matchpoint = angular.module('matchpointApp', [
  'ngRoute',
  'templates',
  'ResourceModule',
  'angular.filter',
  'ui.bootstrap',
  'restangular',
  'HomeModule',
  'FriendsModule',
  'CourtsModule',
  'MatchesModule',
  'ChatsModule',
  'SettingsModule',
  'matchpointWidgetsModule'
]);

matchpoint.config(['$routeProvider', function ($routeProvider) {
  $routeProvider.
      otherwise({
        redirectTo: '/'
      });
}]);

//addErrorReporting(matchpoint);
addRouting(matchpoint);

// Fix issue https://github.com/angular-ui/bootstrap/issues/2169
// in bootstrap UI through monkeypatching.  Delete once we upgrade past v0.11
matchpoint.config(['$provide', function ($provide) {

  $provide.decorator('dateParser', function ($delegate) {

    var oldParse = $delegate.parse;
    $delegate.parse = function (input, format) {
      if (!angular.isString(input) || !format) {
        return input;
      }
      return oldParse.apply(this, arguments);
    };

    return $delegate;
  });
}]);

var homeModule = angular.module('HomeModule', ['ngSanitize']);

homeModule.config(['$routeProvider',
  function ($routeProvider) {
    $routeProvider.
    when('/', {
      templateUrl: 'main/index/home_nav.html',
      controller: 'HomeNavController as ctrl'
    });
  }]);

homeModule.controller('HomeNavController',
    ['$scope', '$modal', 'resources', function ($scope, $modal, resources) {
      var ctrl = this;

      if (!$scope.user.has_joined_courts) {
        // This is the home page (default view). Redirect users to force joining a court if
        // they haven't yet.
        resources.location.path('courts')
      }

      $scope.year = new Date().getFullYear();

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
