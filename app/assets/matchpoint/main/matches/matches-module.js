var matchesModule = angular.module('MatchesModule', ['ngSanitize']);

matchesModule.config(['$routeProvider',
  function ($routeProvider) {
    $routeProvider.
    when('/match_requests', {
      templateUrl: 'main/matches/matches.html',
      controller: 'MatchRequestsListController as ctrl'
    }).
    when('/my_matches', {
      templateUrl: 'main/matches/matches.html',
      controller: 'MyMatchesListController as ctrl'
    }).
    when('/past_matches', {
      templateUrl: 'main/matches/matches.html',
      controller: 'PastMatchesListController as ctrl'
    }).
    when('/new_match', {
      templateUrl: 'main/matches/new_match.html',
      controller: 'NewMatchRequestsController as ctrl'
    });
  }]);

var BaseMatchesListController = function ($scope, resources, matchType) {
  var ctrl = this;
  $scope.matchType = matchType;

  ctrl.getMatches = function() {
    resources.all('matches?' + matchType + '=true').getList().then(function (matches) {
      $scope.matches = matches;
    });
  };

  ctrl.goToMatchRequestDetailPage = function(id) {
    resources.location.path('matches/' + id);
  };

  ctrl.getMatches();
};

matchesModule.controller('MatchRequestsListController',
    ['$scope', 'resources', function ($scope, resources) {
      var ctrl = this;

      BaseMatchesListController.call(this, $scope, resources, 'requests');

      $scope.pageTitle = 'MATCH REQUESTS';

      ctrl.joinMatch = function (match) {
        resources.all('matches/join/' + match.id).customPOST().then(function () {
          ctrl.getMatches();
        });
      };
    }]);

matchesModule.controller('MyMatchesListController',
    ['$scope', 'resources', function ($scope, resources) {
      var ctrl = this;

      BaseMatchesListController.call(this, $scope, resources, 'my_matches');

      $scope.pageTitle = 'MY MATCHES';

      ctrl.leaveMatch = function (match) {
        resources.all('matches/leave/' + match.id).customDELETE().then(function () {
          ctrl.getMatches();
        });
      };
    }]);

matchesModule.controller('PastMatchesListController',
    ['$scope', 'resources', function ($scope, resources) {
      BaseMatchesListController.call(this, $scope, resources, 'past_matches');

      $scope.pageTitle = 'PAST MATCHES';
    }]);

matchesModule.controller('NewMatchRequestsController',
    ['$scope', 'resources', function ($scope, resources) {
      var ctrl = this;

      $scope.match = {};

      resources.all('courts?joined=true').getList().then(function (courts) {
        $scope.courts = courts;
      });

      ctrl.createMatch = function() {
        $scope.match.match_date = $scope.match.match_date.addHours($scope.match.match_time/2);
        resources.success_message(
            resources.all('matches').post($scope.match), "Match created")
            .then(function () {
              resources.location.path('/my_matches');
              return false;
            });
      };

      return ctrl;
    }]);
