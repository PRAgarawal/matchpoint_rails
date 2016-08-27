matchpoint = angular.module('matchpointApp', [
  'ngRoute',
  'templates',
  'ResourceModule',
  'angular.filter',
  'ui.bootstrap',
  'restangular',
  'FriendsModule',
  'CourtsModule',
  'MatchesModule',
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
