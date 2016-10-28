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

function openMatchJoinedModal($scope, resources, $modal, match) {
  $modal.open({
    templateUrl: 'main/matches/match_joined_modal.html',
    controller: 'MatchJoinedModalController as ctrl',
    'size': 'lg',
    'scope': $scope,
    'resources': resources,
    'resolve': {
      'match': function() {
        return match;
      }
    }
  });
}

var BaseMatchesListController = function ($scope, $modal, resources, matchType) {
  var ctrl = this;
  $scope.matchType = matchType;

  ctrl.timezone = function(match) {
      return /\((.*)\)/.exec(new Date(match.match_date).toString())[1];
  }

  ctrl.getMatches = function() {
    $scope.matches = [];
    resources.all('matches?' + matchType + '=true').getList().then(function (matches) {
      $scope.matches = matches;
    });
  };

  ctrl.goToMatchRequestDetailPage = function(id) {
    resources.location.path('matches/' + id);
  };

  ctrl.showUserModal = function(user) {
    openUserInfoModal(user, $modal, $scope, resources);
  };

  ctrl.getMatches();
};

matchesModule.controller('MatchRequestsListController',
    ['$scope', '$modal', 'resources', function ($scope, $modal, resources) {
      if (!$scope.user.has_joined_courts) {
        // The match requests page is the default view right now, so redirect users to force
        // joining a court if they haven't yet.
        // TODO: Make the "home" page just the buttons to select various other pages
        resources.location.path('courts')
      }
      mixPanelEvts.navigateMatchRequests();
      var ctrl = this;

      BaseMatchesListController.call(this, $scope, $modal, resources, 'requests');

      $scope.pageTitle = 'MATCH REQUESTS';

      ctrl.joinMatch = function (match, joinMethod) {
        resources.all('matches/join/' + match.id).customPOST().then(function () {
          mixPanelEvts.joinMatch(match, joinMethod);
          openMatchJoinedModal($scope, resources, $modal, match);
          ctrl.getMatches();
        });
      };

      if (resources.routeParams.joinMatchId) {
        resources.one('matches/' + resources.routeParams.joinMatchId).get().then(function (match) {
          ctrl.joinMatch(match, 'from_email');
        });
      }
    }]);

matchesModule.controller('MyMatchesListController',
    ['$scope', '$modal', 'resources', function ($scope, $modal, resources) {
      mixPanelEvts.navigateMyMatches()
      var ctrl = this;

      BaseMatchesListController.call(this, $scope, $modal, resources, 'my_matches');

      $scope.pageTitle = 'MY MATCHES';

      ctrl.leaveMatch = function (match) {
        resources.all('matches/leave/' + match.id).customDELETE().then(function () {
          mixPanelEvts.leaveMatch(match, 'from_my_matches');
          ctrl.getMatches();
        });
      };
    }]);

matchesModule.controller('PastMatchesListController',
    ['$scope', '$modal', 'resources', function ($scope, $modal, resources) {
      mixPanelEvts.navigatePastMatches();
      BaseMatchesListController.call(this, $scope, $modal, resources, 'past_matches');

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
            .then(function (match) {
              mixPanelEvts.createMatch(match);
              resources.location.path('my_matches');
              return false;
            });
      };

      return ctrl;
    }]);

matchesModule.controller('MatchJoinedModalController',
    ['$scope', 'resources', '$modalInstance', 'match', function ($scope, resources, $modalInstance, match) {
      var ctrl = this;

      $scope.match = match;

      ctrl.cancel = function() {
        $modalInstance.close('cancel');
        resources.location.search('joinMatchId', null);
      }
    }]);
