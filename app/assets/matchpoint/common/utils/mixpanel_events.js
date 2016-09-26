function mixPanelMatchInfo(match) {
  return {
    'match_id':   match.id,
    'game_type':  match.is_singles ? 'singles' : 'doubles',
    'location':   match.court.name,
    'court_id':   match.court.id,
    'date':       match.match_date,
    'visibility': match.is_friends_only ? 'friends only' : 'friends and courts'
  }
}

function mixPanelIsMatchFull(match) {
  return (match.is_singles && match.users.length == 2) || (match.users.length == 4);
}

var mixPanelEvts = {
  // --------- FRIEND EVENTS ---------
  addFriend: function(friendFinder) {
    var friend = {};
    if (friendFinder.is_email()) {
      friend['email'] = friendFinder;
    } else {
      friend['code'] = friendFinder;
    }
    mixpanel.track("Friend invite", friend);
    mixpanel.people.increment('friends_invited');
  },
  inviteFriend: function(friendEmail) {
    mixpanel.track("New friend invite", {
      'friend': friendEmail
    });
    mixpanel.people.increment('new_friends_invited');
  },
  friendRequestAccept: function(friend) {
    mixpanel.track("Friend request accept", {
      'friend': friend.email
    });
  },
  friendRequestReject: function(friend) {
    mixpanel.track("Friend request reject", {
      'friend': friend.email
    });
  },
  friendRemove: function(friend) {
    mixpanel.track("Friend remove", {
      'friend': friend.email
    });
  },

  // --------- COURT EVENTS ---------
  joinCourt: function(court) {
    mixpanel.track("Court player join", {
      'court_id': court.id,
      'name':     court.name
    });
    mixpanel.people.increment('courts');
  },
  leaveCourt: function(court) {
    mixpanel.track("Court player leave", {
      'court_id': court.id,
      'name':     court.name
    });
    mixpanel.people.increment('courts', -1);
  },

  // --------- MATCH EVENTS ---------
  createMatch: function(match) {
    mixpanel.track("Match create", mixPanelMatchInfo(match));
  },
  joinMatch: function(match) {
    mixpanel.track("Match player join", mixPanelMatchInfo(match));
    // Notify match is full depending on whether this is a singles or doubles match
    if (mixPanelIsMatchFull(match)) {
      mixpanel.track("Match full", mixPanelMatchInfo(match));
    }
  },
  leaveMatch: function(match) {
    mixpanel.track("Match player leave", mixPanelMatchInfo(match));
    if (match.users.length == 1) {
      mixpanel.track("Match delete", mixPanelMatchInfo(match));
    } else if (mixPanelIsMatchFull(match)) {
      mixpanel.track("Match full to open", mixPanelMatchInfo(match));
    }
  },

  // --------- MESSAGE EVENTS ---------
  matchMessage: function(match) {
    mixpanel.track("Match message sent", mixPanelMatchInfo(match));
  }
};
