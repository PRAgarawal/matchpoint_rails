function mixPanelMatchInfo(match) {
  return {
    'match_id':   match.id,
    'game_type':  match.is_singles ? 'singles' : 'doubles',
    'location':   match.court.name,
    'court_id':   match.court.id,
    'date':       match.match_date,
    'visibility': match.is_friends_only ? 'friends only' : 'friends and courts'
  };
}

function mixPanelFriendInfo(friend) {
  return {
    'friend_first_name': friend.first_name,
    'friend_last_name': friend.last_name,
  };
}

function mixPanelIsMatchFull(match, beforeLeave) {
  var userCount = beforeLeave ? match.users.length : match.users.length + 1;
  return (match.is_singles && userCount == 2) || (userCount == 4);
}

var mixPanelEvts = {
  // --------- PAGE NAVIGATION --------
  navigateFriends: function() {
    mixpanel.track("Navigate 'Friends'");
  },
  navigateMyMatches: function() {
    mixpanel.track("Navigate 'My Matches'");
  },
  navigateMatchRequests: function() {
    mixpanel.track("Navigate 'Match Requests'");
  },
  navigateCreateMatch: function() {
    mixpanel.track("Navigate 'Create Match'")
  },
  navigateRecordScore: function() {
    mixpanel.track("Navigate 'Record Score'")
  },
  navigatePastMatches: function() {
    mixpanel.track("Navigate 'Past Matches'");
  },
  navigateCourts: function() {
    mixpanel.track("Navigate 'Courts'");
  },
  navigateRequestCourt: function() {
    mixpanel.track("Navigate 'Request a New Court'");
  },
  navigateSendFeedback: function() {
    mixpanel.track("Navigate 'Send Feedback'");
  },
  navigateSettings: function() {
    mixpanel.track("Navigate 'Settings'");
  },
  navigateChangePassword: function() {
    mixpanel.track("Navigate 'Change Password'");
  },
  navigateHome: function() {
    mixpanel.track("Navigate 'Home'");
  },
  navigateUserProfile: function() {
    mixpanel.track("Navigate 'User Profile'");
  },
  navigateJoinCourt: function() {
    mixpanel.track("Navigate 'Join Courts'");
  },
  navigateMostActive: function() {
    mixpanel.track("Navigate 'Most Active'");
  },
  // --------- FRIEND EVENTS ---------
  addFriend: function(friendFinder) {
    var friend = {};
    if (typeof friendFinder === 'object') {
      friend['friend'] = friendFinder.email;
      friend['method'] = 'user_profile';
    } else if (friendFinder.is_email()) {
      friend['friend'] = friendFinder;
      friend['method'] = 'friends_page_email';
    } else {
      friend['friend'] = friendFinder;
      friend['method'] = 'friends_page_invite_code';
    }
    mixpanel.track("Friend request send", friend);
    mixpanel.people.increment('friends_invited');
  },
  friendRequestAccept: function(friend) {
    mixpanel.track("Friend request accept", mixPanelFriendInfo(friend));
  },
  friendRequestReject: function(friend) {
    mixpanel.track("Friend request reject", mixPanelFriendInfo(friend));
  },
  friendRemove: function(friend) {
    mixpanel.track("Friend remove", mixPanelFriendInfo(friend));
  },

  // --------- INVITE EVENTS ---------
  textInvite: function() {
    mixpanel.track("Text invite");
  },
  navigateInvite: function() {
    mixpanel.track("Navigate 'Invite'");
  },
  emailInvite: function(friendEmail) {
    mixpanel.track("New friend invite", {
      'friend': friendEmail
    });
    mixpanel.people.increment('new_friends_invited');
  },

  // --------- COURT EVENTS ---------
  joinCourt: function(court) {
    mixpanel.track("Court player join", {
      'court_id':   court.id,
      'court_name': court.name
    });
    mixpanel.people.increment('courts');
  },
  leaveCourt: function(court) {
    mixpanel.track("Court player leave", {
      'court_id':   court.id,
      'court_name': court.name
    });
    mixpanel.people.increment('courts', -1);
  },

  // --------- MATCH EVENTS ---------
  createMatch: function(match) {
    mixpanel.track("Match create", mixPanelMatchInfo(match));
    mixpanel.track("Match player join", mixPanelMatchInfo(match));
  },
  joinMatch: function(match, joinMethod) {
    var matchData = mixPanelMatchInfo(match);
    matchData['join_method'] = joinMethod || 'from_website';
    mixpanel.track("Match player join", matchData);
    // Notify match is full depending on whether this is a singles or doubles match
    if (mixPanelIsMatchFull(match)) {
      mixpanel.track("Match full", matchData);
    }
  },
  leaveMatch: function(match, leaveMethod) {
    var matchData = mixPanelMatchInfo(match);
    matchData['leave_method'] = leaveMethod;
    mixpanel.track("Match player leave", matchData);

    if (match.users.length == 1) {
      mixpanel.track("Match delete", matchData);
    } else if (mixPanelIsMatchFull(match, true)) {
      mixpanel.track("Match full to open", matchData);
    }
  },
  scoreSubmitted: function(match) {
    var matchData = mixPanelMatchInfo(match);
    mixpanel.track("Match score submitted", matchData);
  },

  // --------- MESSAGE EVENTS ---------
  matchMessageSend: function(match) {
    mixpanel.track("Match chat message send", mixPanelMatchInfo(match));
  },
  matchChatView: function(match) {
    mixpanel.track("Match chat view", mixPanelMatchInfo(match));
  },
  courtRequestSubmit: function(court) {
    mixpanel.track("Court request submit", {
      'court_name': court.name,
      'metro': court.is_dfw ? "DFW" : "SF"
    });
  },
  changePassword: function() {
    mixpanel.track("Password change");
  }
};
