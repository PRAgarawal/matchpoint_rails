var chatsModule = angular.module('ChatsModule', ['ngSanitize']);

chatsModule.config(['$routeProvider',
  function ($routeProvider) {
    $routeProvider.
    when('/chats/:chatId/:matchId', {
      templateUrl: 'main/chats/chat.html',
      controller: 'ChatController as ctrl'
    });
  }]);

chatsModule.controller('ChatController',
    ['$scope', 'resources', '$modal', 'matchpointModals', function ($scope, resources, $modal, matchpointModals) {
      var ctrl = this;
      var chatId = resources.routeParams.chatId;
      var oldest = new Date((new Date()).getTime() + TWO_DAYS_AGO);
      var latest = new Date((new Date()).getTime() + TWO_HOURS_AGO);
      var matchUser0, matchUser1;
      $scope.message = {chat_id: chatId};

      resources.one('matches/' + resources.routeParams.matchId).get().then(function (match) {
        mixPanelEvts.matchChatView(match);
        $scope.match = match;
        matchUser0 = match.match_users[0];
        matchUser1 = match.match_users[1];
      });

      ctrl.timezone = function(match) {
        if (!match) {return null}
        return /\((.*)\)/.exec(new Date(match.match_date).toString())[1];
      };

      function getMessages() {
        resources.all('messages?chat_id=' + chatId).getList().then(function (messages) {
          $scope.messages = messages;
        });
      }

      ctrl.sendMessage = function() {
        var message = angular.copy($scope.message);
        $scope.message = {chat_id: chatId};
        resources.all('messages').post(message).then(function () {
          mixPanelEvts.matchMessageSend($scope.match);
          getMessages();
        });
      };

      ctrl.showUserModal = function(user) {
        openUserInfoModal(user, $modal, $scope, resources);
      };

      ctrl.leaveMatch = function () {
        leaveMatchModal(matchpointModals, resources, ctrl, $scope.match, 'from_match_detail', function(){
            resources.location.path('my_matches');
        });
      };
      
      ctrl.shouldShowName = function(message) {
        var i = $scope.messages.indexOf(message);
        var previousMessage = i < $scope.messages.length - 1 ? $scope.messages[i+1] : {user_id: -1};
        return (message.user_id != $scope.user.id) && (previousMessage.user_id != message.user_id);
      };

      ctrl.matchInFuture = function() {
        if (!$scope.match) {
          return false;
        }
        return new Date($scope.match.match_date) > new Date();
      };

      ctrl.canRecordScore = function() {
        return canRecordScore($scope.match, oldest, latest);
      };

      function getWinningUserName(userId) {
        if (!$scope.match) {
          return false;
        }

        for (var i=0; i < $scope.match.users.length; i++) {
          var user = $scope.match.users[i]
          if (user.id == userId) {
            return user.first_name;
          }
        }
        return false;
      }

      ctrl.winningUser = function() {
        if (!$scope.match) {
          return false;
        }

        if ($scope.match.match_users[0].is_winner) {
          return getWinningUserName($scope.match.match_users[0].user_id);
        } else if ($scope.match.match_users[1].is_winner) {
          return getWinningUserName($scope.match.match_users[1].user_id);
        }

        return false;
      };

      function getSetScoreText(setNum) {
        var userScore0 = matchUser0['set_' + setNum + '_total'];
        var userScore1 = matchUser1['set_' + setNum + '_total'];
        var winningUser, winningText;

        if (isNaN(userScore0) || isNaN(userScore1)) {
          return false;
        }

        if (userScore0 >= userScore1) {
          winningUser = getWinningUserName(matchUser0.user_id);
          winningText = winningUser + " " + userScore0 + "-" + userScore1;
        } else {
          winningUser = getWinningUserName(matchUser1.user_id);
          winningText = winningUser + " " + userScore1 + "-" + userScore0;
        }

        return winningText;
      }

      ctrl.set1Score = function() {
        return getSetScoreText(1);
      };

      ctrl.set2Score = function() {
        return getSetScoreText(2);
      };

      ctrl.set3Score = function() {
        return getSetScoreText(3);
      };
      
      getMessages();
    }]);
