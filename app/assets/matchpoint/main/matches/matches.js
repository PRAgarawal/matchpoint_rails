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
    when('/match_requests/new', {
      templateUrl: 'main/matches/new_match_request.html',
      controller: 'NewMatchRequestsController as ctrl'
    }).
    when('/match_requests/:id', {
      templateUrl: 'main/matches/match_request.html',
      controller: 'ViewMatchRequestController as ctrl'
    });
  }]);

var BaseMatchesListController = function ($scope, resources) {
  var ctrl = this;

  resources.all('match_requests').getList().then(function (match_requests) {
    $scope.matchRequests = match_requests;
  });

  ctrl.goToMatchRequestDetailPage = function(id) {
    resources.location.path('match_requests/' + id);
  };
};

matchesModule.controller('MatchRequestsListController',
    ['$scope', 'resources', function ($scope, resources) {
      BaseMatchesListController.call(this, $scope, resources);

      $scope.pageTitle = 'MATCH REQUESTS';
    }]);

matchesModule.controller('MyMatchesListController',
    ['$scope', 'resources', function ($scope, resources) {
      BaseMatchesListController.call(this, $scope, resources);

      $scope.pageTitle = 'MY MATCHES';
    }]);

matchesModule.controller('PastMatchesListController',
    ['$scope', 'resources', function ($scope, resources) {
      BaseMatchesListController.call(this, $scope, resources);

      $scope.pageTitle = 'PAST MATCHES';
    }]);

matchesModule.controller('NewMatchRequestsController',
    ['$scope', 'resources', function ($scope, resources) {
      var ctrl = this;

      $scope.matchRequest = {
      };

      ctrl.submitMatchRequest = function() {
        //TODO: Make this a create
        resources.all('match_requests').getList().then(function (match_requests) {
          $scope.matchRequests = match_requests;
        });
      };

      return ctrl;
    }]);

matchesModule.controller('ViewMatchRequestController',
    ['$scope', 'resources', function ($scope, resources) {
    }]);
