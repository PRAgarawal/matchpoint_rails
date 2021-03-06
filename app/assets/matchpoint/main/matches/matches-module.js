var matchesModule = angular.module('MatchesModule', ['ngSanitize']);

matchesModule.filter("skill", function(){
  return function (skill) {
    switch(skill) {
      case 8:
        return "Pro";
      case 7:
        return "Open";
      case 6:
        return "Elite";
      case 5:
        return "A";
      case 4:
        return "B";
      case 3:
        return "C";
      case 2:
        return "D";
    }
  }
});

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
    }).
    when('/match_score/:matchId', {
      templateUrl: 'main/matches/match_score.html',
      controller: 'MatchScoreController as ctrl'
    });
  }]);

function isMatchFull(match) {
  return (match.is_singles && match.users.length == 2) || (match.users.length == 4);
}

function isNoScore(match) {
  return (match.match_users.length > 0) && (match.match_users[0].is_winner === null);
}

var TWO_DAYS_AGO = -48*60*60*1000;
var ONE_HOUR_AGO = -1*60*60*1000;
function canRecordScore(match, oldest, latest) {
  if (!match) {
    return false;
  }
  var matchDate = new Date(match.match_date);
  return (matchDate > oldest) && (matchDate < latest) && match.is_singles && isMatchFull(match) && isNoScore(match);
}

function getUserNameFromId($scope, userId) {
  if (!$scope.match) {
    return '';
  }

  for (var i=0; i < $scope.match.users.length; i++) {
    var user = $scope.match.users[i];
    if (user.id == userId) {
      return user.first_name + " " + user.last_name;
    }
  }
  return '';
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

function leaveMatchModal(matchpointModals, resources, ctrl, match, mpMessage, callback) {
    matchpointModals.genericConfirmation(function() {
        resources.all('matches/leave/' + match.id).customDELETE().
        then(function () {
            mixPanelEvts.leaveMatch(match, mpMessage);
            callback();
        });
    }, "leave this match? You will no longer be able to receive or send messages with others in this match.", "Confirm", "Yes");
}

var BaseMatchesListController = function ($scope, $modal, resources, matchType) {
  var ctrl = this;
  var oldest = new Date((new Date()).getTime() + TWO_DAYS_AGO);
  var latest = new Date((new Date()).getTime());
  $scope.matchType = matchType;
  $scope.dataLoading = true;

  ctrl.timezone = function(match) {
      return /\((.*)\)/.exec(new Date(match.match_date).toString())[1];
  };

  ctrl.getMatches = function() {
    $scope.matches = [];
    resources.all('matches?' + matchType + '=true').getList().then(function (matches) {
      $scope.matches = matches;
      $scope.dataLoading = false;
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

  ctrl.canRecordScore = function(match) {
    return canRecordScore(match, oldest, latest);
  };

  ctrl.isWinner = function(match, user) {
    for(var i = 0; i < match.match_users.length; i++) {
      if (match.match_users[i].user_id == user.id && match.match_users[i].is_winner) {
        return true;
      }
    }
    return false;
  };

  ctrl.getMatches();
};

matchesModule.controller('MatchRequestsListController',
    ['$scope', '$modal', 'resources', function ($scope, $modal, resources) {
      mixPanelEvts.navigateMatchRequests();
      mixpanel.people.set({"Metro" : ($scope.user.is_dfw ? "DFW" : "SF")});
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
        leaveMatchModal(matchpointModals, resources, ctrl, match, 'from_my_matches', function(){
          ctrl.getMatches();
          });
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
      mixPanelEvts.navigateCreateMatch();
      var ctrl = this;

      $scope.match = {};

      resources.all('courts?joined=true').getList().then(function (courts) {
        $scope.courts = courts;
      });

      ctrl.timezone = function() {
          return /\((.*)\)/.exec(new Date().toString())[1];
      };

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

matchesModule.controller('MatchScoreController',
    ['$scope', 'resources', 'matchpointModals', function ($scope, resources, matchpointModals) {
      mixPanelEvts.navigateRecordScore();
      var ctrl = this;

      resources.one('matches/' + resources.routeParams.matchId).get().then(function (match) {
        mixPanelEvts.matchChatView(match);
        $scope.match = match;
        $scope.match.score_submitter_id = $scope.user.id;
        $scope.firstUserName = getUserNameFromId($scope, $scope.match.match_users[0].user_id);
        $scope.secondUserName = getUserNameFromId($scope, $scope.match.match_users[1].user_id);
      });

      function isInvalidScoreData() {
        if ($scope.match.winningUserId === undefined || $scope.match.match_users[0].set_1_total == null || $scope.match.match_users[1].set_1_total == null) {
          // User did not fill out all necessary match data
          matchpointModals.error('You must select a winner and enter a valid score.', 'Invalid data');
          return true;
        }

        return false;
      }

      ctrl.submitScore = function() {
        if (isInvalidScoreData()) {
          return;
        }
        $scope.match.match_users[0].is_winner = $scope.match.winningUserId == $scope.match.match_users[0].user_id;
        $scope.match.match_users[1].is_winner = $scope.match.winningUserId == $scope.match.match_users[1].user_id;
        resources.all('matches/' + $scope.match.id).customPUT($scope.match).then(function (match) {
          mixPanelEvts.scoreSubmitted(match);
          matchpointModals.genericConfirmation(null, "Score submitted", "Success", "OK", true);
          resources.location.path('chats/' + $scope.match.chat.id + "/" + $scope.match.id);
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
