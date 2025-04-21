
var app = angular.module('beamng.apps')


app.config(['$compileProvider', function($compileProvider) {

  // Allow additional URL patterns for img src attributes
  $compileProvider.imgSrcSanitizationWhitelist(/^\s*(https?|ftp|file|blob|local|mailto):|data:image\/(png|jpg|jpeg|gif|svg\+xml);/);}])

app.filter('unique', function() {
    return function(items) {
        if (!items) return [];
        let uniqueItems = [];
        let seenItems = new Set();
        if (Array.isArray(items)) {
          items.forEach(item => {
              if (!seenItems.has(item)) {
                  seenItems.add(item);
                  uniqueItems.push(item);
              }
          });
        }
        return uniqueItems;
    };
});

app.filter('groupBy', function(){
  return function(list, group_by) {

  var filtered = [];
  var prev_item = null;
  var group_changed = false;
  // this is a new field which is added to each item where we append "_CHANGED"
  // to indicate a field change in the list
  var new_field = group_by + '_CHANGED';

  // loop through each item in the list
  angular.forEach(list, function(item) {

    group_changed = false;

    // if not the first item
    if (prev_item !== null) {

      // check if the group by field changed
      if (prev_item[group_by] !== item[group_by]) {
        group_changed = true;
      }

    // otherwise we have the first item in the list which is new
    } else {
      group_changed = true;
    }

    // if the group changed, then add a new field to the item
    // to indicate this
    if (group_changed) {
      item[new_field] = true;
    } else {
      item[new_field] = false;
    }

    filtered.push(item);
    prev_item = item;

  });

  return filtered;
  };
})

app.directive('commandInputs', function() {
  return {
      restrict: 'E',
      scope: {
          command: '=',
          argsModel: '=',
          sendCommand: '&',
          onClickOutside: '&',
          clickOutsideExceptions: '@'
      },
      template: `
          <div class="command-inputs" click-outside="onClickOutside()" click-outside-exceptions="{{clickOutsideExceptions}}">>
              <div class="command-arg" ng-repeat="arg in command.args.slice(1)">
                  <input type="text" placeholder="{{capitalizeFirstLetter(arg.name)}} ({{arg.type}})" 
                         ng-model="argsModel[arg.name]" ng-if="arg.type === 'string'" />
                  <!-- Ajoutez d'autres types d'arguments ici -->
              </div>
              <button ng-click="sendCommand({commandName: command.name})">Send Command</button>
          </div>
      `
  };
});


app.directive('clickOutside', ['$document', function($document) {
  return {
    restrict: 'A',
    scope: {
      clickOutside: '&',
      clickOutsideExceptions: '@' // liste de classes séparées par des virgules
    },
    link: function(scope, element) {
      function onClick(event) {
        const exceptions = scope.clickOutsideExceptions
          ? scope.clickOutsideExceptions.split(',').map(cls => cls.trim())
          : [];

        // Vérifie si l'élément cliqué ou un de ses parents contient une des classes exception
        const isException = exceptions.some(className =>
          event.target.closest('.' + className)
        );

        if (!element[0].contains(event.target) && !isException) {
          scope.$apply(() => {
            scope.$eval(scope.clickOutside);
          });
        }
      }

      $document.on('click', onClick);

      scope.$on('$destroy', function() {
        $document.off('click', onClick);
      });
    }
  };
}]);

app.directive('nickel', [function () {
  return {
    templateUrl:  '/ui/modules/apps/Nickel/app.html',
    replace: true,
    restrict: 'EA',
    scope: true,
    controller: ['$scope', '$timeout', '$sce', function($scope, $timeout, $sce) {
  
      $scope.hideCard = true
      $scope.hideAddRoles = true
      $scope.hideRoles = true
      $scope.hideUserCommandInputs = true
      $scope.hideGlobalCommandInputs = true


      $scope.nkinit = function() {
 
          console.log("NKinit triggered")
          bngApi.engineLua('extensions.Nickel.initializeInterface(0)')
          setTimeout(function() {
              registerCustomEvents($scope);
              console.log("Angular calling client lua ...")
          }, 5000);
      }
 

      $timeout($scope.nkinit, 1000)
      

      // // called on load
      // $scope.$on('NKinit', function (event) {
      //   nkinit()
      // });

      $scope.imgSafe = function(url){
        return $sce.trustAsResourceUrl(url);

      };

      // $scope.nkplayers = {0:{"name":"bouboule", "roles":{
      //   0:{"roleName":"Administrator", "permlvl":3},
      //   1:{"roleName":"Member", "permlvl":1}
      // }}}

      // $scope.nkroles = {0:{"roleName":"Administrator", "permlvl":3}}

    $scope.hideSelectIcon = function() {
            var icon = document.querySelector('.meteo-input .md-select-icon');
            if (icon) {
                icon.style.display = 'none';
            }
        };

    $scope.$on('NKgetUserCommands', function (event, data) {
        console.log("triggered NKgetUserCommands", data)
        $scope.$apply(() => {
        $scope.user_commands = data
        console.log($scope.user_commands)
        });
    });
    $scope.$on('NKgetGlobalCommands', function (event, data) {
        console.log("triggered NKgetGlobalCommands", data)
        $scope.$apply(() => {
        $scope.global_commands = data
        console.log($scope.global_commands)
        $scope.groupedGlobalCommands = getGroupedGlobalCommands();
        console.log($scope.groupedGlobalCommands)
        });
    });
    $scope.$on('NKgetUserValues', function (event, data) {
      $scope.$apply(() => {
      console.log(data)      
      $scope.canEditEnvironment = hasAction('editEnvironment', data.self_action_perm)
      });
    });

    $scope.$on('NKgetServerValues', function (event, data) {
      $scope.$apply(() => {
        $scope.nkserver_version = data.server_version
      });
    });
    $scope.$on('getPlayers', function (event, data) {
      $scope.$apply(() => {
        $scope.nkplayers = data
        console.log(data)
      });

    });
    $scope.$on('getRoles', function (event, data) {
      $scope.$apply(() => {
      $scope.nkroles = data.sort((a, b) => b.permlvl - a.permlvl); 
      });
    });
    $scope.$on('SyncEnvironment', function (event, data) {
      $scope.$apply(() => {
      $scope.game_temp = data.temperature
      $scope.game_gravity = data.gravity
      $scope.game_wind = data.wind
      $scope.game_meteo = data.meteo
      if(parseInt(data.time[0],10)<10)data.time[0]='0'+data.time[0];
      if(parseInt(data.time[1],10)<10)data.time[1]='0'+data.time[1];
      $scope.game_time = data.time
      });

      
    });
    $scope.$on('SyncWeatherPresets', function (event, data) {
      $scope.$apply(() => {
      $scope.weatherPresets = data
      });
    });

    $scope.resizeApp = function() {
      let element = document.querySelector(".main-container")
      let element2 = document.querySelector(".arrow-icon")

      if (localStorage.getItem("NKclosed") == "false"){
        localStorage.setItem("NKclosed", true);
        element2.classList.add("arrow-icon-reverse")

        element.classList.add("NKclosed")
      }else{
        element2.classList.remove("arrow-icon-reverse")
        element.classList.remove("NKclosed")
        localStorage.setItem("NKclosed", false);
      }


    }
    $scope.roleExists = function(roleName, roles) {
      if (!Array.isArray(roles)) {
        return false;
      }
      return roles.some(function(role) {
          return role.name === roleName;
      });
    };
    $scope.getHighestRole = function(roles) {
      if (roles.length === 0) {
          return null; // Handle the case where the roles array is empty
      }
    
    
      return roles.reduce((highestRole, currentRole) => {
          return currentRole.permlvl > highestRole.permlvl ? currentRole : highestRole;
      });
    };


    $scope.showPlayerCard = function(event, index) {
      if (!$scope.hideCard && $scope.playerIndex === index) {
        return
      }
      const playerCard = document.querySelector(".player-card")
      const buttonRect = event.target.getBoundingClientRect(); 
      const playerCardParent = playerCard.parentElement.getBoundingClientRect();
      $scope.playerIndex = index
      playerCard.style.top = `${(buttonRect.bottom - playerCardParent.top - 10) + playerCard.parentElement.scrollTop}px`;
      $scope.hideCard = false  
     
     
    };

    $scope.showRoles = function() {
      if ($scope.hideRoles) {
        $scope.hideRoles = false
      }else{
        $scope.hideRoles = true
      }
     
    }

    $scope.selectUserCommand = function(commandName) {
      $scope.hideUserCommandInputs = false;
      $scope.selectedUserCommand = $scope.user_commands[commandName];
      $scope.selectedUserCommand.name = commandName;
      $scope.usercommandArgs = {};
      // Ignore the first argument (playername)
      $scope.selectedUserCommand.args.slice(1).forEach(arg => {
        $scope.usercommandArgs[arg.name] = '';
      });
    };

    $scope.selectGlobalCommand = function(commandName) {
      $scope.hideGlobalCommandInputs = false;
      $scope.selectedGlobalCommand = $scope.global_commands[commandName];
      $scope.selectedGlobalCommand.name = commandName;
      $scope.globalcommandArgs = {};

    }
  

    $scope.sendUserCommand = function(commandName) {
      const command = $scope.user_commands[commandName];
      const args = $scope.usercommandArgs;
      let argsString = '';
      // Ignore the first argument (playername)
      command.args.slice(1).forEach(arg => {
        argsString += `"${args[arg.name]}", `;
      });
      argsString = argsString.slice(0, -2); // Remove the trailing comma and space
      bngApi.engineLua(`extensions.Nickel.sendCommand("${commandName}", {"${$scope.nkplayers[$scope.playerIndex].name}", ${argsString}})`);
    };

    $scope.sendGlobalCommand = function(commandName) {
      const command = $scope.global_commands[commandName];
      const args = $scope.globalcommandArgs;
      let argsString = '';
      command.args.forEach(arg => {
        argsString += `"${args[arg.name]}", `;
      });
      argsString = argsString.slice(0, -2); // Remove the trailing comma and space
      bngApi.engineLua(`extensions.Nickel.sendCommand("${commandName}", {${argsString}})`);
    };

    $scope.showAddRoles = function() {
      $scope.hideAddRoles = false  
    }

    $scope.addRole = function(rolename, player) {
      bngApi.engineLua(`extensions.Nickel.addRole("${rolename}", "${player}")`)
    }
    $scope.removeRole = function(rolename, player) {
      bngApi.engineLua(`extensions.Nickel.removeRole("${rolename}", "${player}")`)
    }

    $scope.capitalizeFirstLetter = function(str) {
      if (!str) return str;
      return str.charAt(0).toUpperCase() + str.slice(1);
    }

    $scope.hasActiveStatus = function(player) {
      if (Object.keys(player.status).length == 0) {
        return false; // Handle the case where player or status is not defined
      }
      return player.status.some(function(status) {
          return status.status_value === 1;
      });
  };

     function getGroupedGlobalCommands() {
      if (!$scope.global_commands) return {}; // Si global_commands n'est pas encore défini
      let grouped = {};
      angular.forEach($scope.global_commands, function(value, key) {
          let ext = value.extension || 'unknown';
          if (!grouped[ext]) {
              grouped[ext] = {};
          }
          grouped[ext][key] = value;
      });
      return grouped;
  };



  }]

  }
}]);


app.directive('hideCategoryIfEmpty', function() {
  return {
      restrict: 'A',
      link: function(scope, element, attrs) {
          // Watch the expression passed to the directive
          scope.$watch(function() {
              if (element[0].children[1].children.length > 0) {
                element.css('display', '');
              } else {
                element.css('display', 'none');
              }
          });
      }
  };
});


const intervalID = setInterval(function resizeCategoryLines(){
  
  let lines = document.querySelectorAll(".category-line")

  lines.forEach(element => {
    let height = element.parentElement.parentElement.querySelector(".category-content").clientHeight
    element.style.height = height + 5 + "px"
  });

}, 500);

function hasAction(actionName, actions) {
  //work on array and objects
  if (Array.isArray(actions)) {
    return actions.includes(actionName);
  } else if (typeof actions === 'object') {
    return actions[actionName];
  }
};

function registerCustomEvents($scope) {
    // Gestion du défilement de la liste des joueurs
    let playerlist = document.querySelector(".player-list");
    const onscroll = () => {
        const isReachBottom = playerlist.scrollTop + playerlist.clientHeight >= playerlist.scrollHeight;
        if (isReachBottom) bngApi.engineLua('extensions.Nickel.updatePlayerList()');
    };
    playerlist.addEventListener("scroll", onscroll);

    // Gestion de la recherche
    let search = document.getElementById("NKsearch");
    const onsearch = () => {
      if ($scope.search === "") {
        bngApi.engineLua('extensions.Nickel.initializeInterface(0)')
      } else{
        bngApi.engineLua('extensions.Nickel.searchPlayer("' + $scope.search + '")');

      }
    };
    search.addEventListener("keyup", onsearch);

    // Gestion des entrées de temps
    const hInput = document.querySelector('.h-input');
    const mInput = document.querySelector('.m-input');
    
    function formatTimeInput(input, max) {
        let value = input.value.replace(/\D/g, '');
        value = value === '' ? '00' : value;
        value = parseInt(value, 10);
        value = Math.min(Math.max(value, 0), max);
        return value.toString().padStart(2, '0');
    }

    function updateTimeInput(input, max) {
        input.value = formatTimeInput(input, max);
        $scope.game_time[input === hInput ? 0 : 1] = input.value;
        $scope.$apply();
    }

    hInput.addEventListener("input", () => updateTimeInput(hInput, 23));
    mInput.addEventListener("input", () => updateTimeInput(mInput, 59));

    // Gestion des autres entrées numériques
    function handleNumericInput(inputElement, scopeVariable) {
      inputElement.addEventListener("input", function() {
          let value = this.value;
          // Permettre uniquement les chiffres, les points décimaux et le signe négatif si autorisé
          value = value.replace(/[^0-9.-]/g, '')
  
          // Si le signe négatif est autorisé, assurez-vous qu'il est uniquement en première position
          if (value.includes('-')) {
              value = '-' + value.replace(/-/g, '');
          }
  
          // Convertir la chaîne en nombre et appliquer les bornes min et max
/*           value = parseFloat(value) || 0;
          value = Math.min(Math.max(value, minValue), maxValue); */
  
          this.value = value;
          $scope[scopeVariable] = value;
          $scope.$apply();
      });

      inputElement.addEventListener("blur", function() {
          if (this.value === '') {
              this.value = '0';
              $scope[scopeVariable] = 0;
              $scope.$apply();
          }
      });
    }
    handleNumericInput(document.querySelector(".temp-input"), 'game_temp');
    handleNumericInput(document.querySelector(".gravity-input"), 'game_gravity');
    handleNumericInput(document.querySelector(".wind-input"), 'game_wind');

    // Watches pour la synchronisation avec le moteur du jeu
    $scope.$watch('game_temp', function(newValue, oldValue) {
        if (newValue !== oldValue && newValue != null && newValue !== "") {
            bngApi.engineLua('extensions.Nickel.setTemp(' + newValue + ')');
        }
    });
  
    $scope.$watch('game_gravity', function(newValue, oldValue) {
        if (newValue !== oldValue && newValue != null && newValue !== "" && !isNaN(parseFloat(newValue)) && isFinite(newValue)) {
            bngApi.engineLua('extensions.Nickel.setGravity(' + newValue + ')');
        }
    });
  
    $scope.$watch('game_time', function(newValue, oldValue) {
        if (newValue !== oldValue && newValue != null && 
            newValue[0] !== "" && newValue[1] !== "" && 
            !isNaN(parseInt(newValue[0])) && isFinite(newValue[0]) &&
            !isNaN(parseInt(newValue[1])) && isFinite(newValue[1])) {
            bngApi.engineLua('extensions.Nickel.setTime(' + newValue[0] + ', ' + newValue[1] + ')');
        }
    }, true);
  
    $scope.$watch('game_wind', function (newValue, oldValue) {
        if (newValue !== oldValue && newValue != null && newValue !== "" && !isNaN(parseFloat(newValue)) && isFinite(newValue)) {
            bngApi.engineLua('extensions.Nickel.setWind(' + newValue + ',' + newValue + ',' + newValue + ')');
        }
    });
    $scope.$watch('game_meteo', function(newValue, oldValue) {
      if (newValue !== oldValue) {
        bngApi.engineLua('extensions.Nickel.setMeteo("' + newValue + '")')
      }
    }); 

    // run func every seconds
    setInterval(function() {
      bngApi.engineLua('extensions.Nickel.jsUpdateEnvironment()');
    }, 1000);
  

  }

  

    // let tempinput = document.querySelector(".temp-input")
    // const onTempInput = (event) => {
    //   bngApi.engineLua('extensions.Nickel.setTemp(' + $scope.game_temp + ')')
    //   }

    // tempinput.addEventListener("keyup", onTempInput)


    // let gravityinput = document.querySelector(".gravity-input")
    // const onGravityInput = (event) => {
    //   bngApi.engineLua('extensions.Nickel.setGravity(' + $scope.game_gravity + ')')
    //   }

    // gravityinput.addEventListener("keyup", onGravityInput)

