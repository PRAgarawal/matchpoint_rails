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

function isMatchFull(match) {
  return (match.is_singles && match.users.length == 2) || (match.users.length == 4);
}

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
  };

  ctrl.getMatches = function() {
    $scope.matches = [];
    resources.all('matches?' + matchType + '=true').getList().then(function (matches) {
      $scope.matches = matches;
    });
  };

  ctrl.getNumEmptySlots = function(match) {
    var numAvailable = 2 * (match.is_singles ? 1 : 2);
    return new Array(numAvailable - match.users.length);
  };

  ctrl.getMatchStatus = function(match) {
    if ($scope.matchType == 'requests') {
      return '';
    } else if ($scope.matchType == 'my_matches') {
      return isMatchFull(match) ? 'full' : 'pending';
    } else if ($scope.matchType == 'past_matches') {
      return isMatchFull(match) ? 'completed' : 'expired';
    }
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
      mixPanelEvts.navigateMatchRequests();
      var ctrl = this;

      BaseMatchesListController.call(this, $scope, $modal, resources, 'requests');

      $scope.pageTitle = 'Match Requests';

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
    ['$scope', '$modal', 'resources', 'matchpointModals', function ($scope, $modal, resources, matchpointModals) {
      mixPanelEvts.navigateMyMatches();
      var ctrl = this;

      BaseMatchesListController.call(this, $scope, $modal, resources, 'my_matches');

      $scope.pageTitle = 'My Matches';

      ctrl.leaveMatch = function (match) {
          matchpointModals.genericConfirmation(function() {
              resources.all('matches/leave/' + match.id).customDELETE().
                  then(function () {
                    mixPanelEvts.leaveMatch(match, 'from_my_matches');
                    ctrl.getMatches();
              });
          }, "leave this match", "Confirm", "Yes");
      };
    }]);

matchesModule.controller('PastMatchesListController',
    ['$scope', '$modal', 'resources', function ($scope, $modal, resources) {
      mixPanelEvts.navigatePastMatches();
      BaseMatchesListController.call(this, $scope, $modal, resources, 'past_matches');

      $scope.pageTitle = 'Past Matches';
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
