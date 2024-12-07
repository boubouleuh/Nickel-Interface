var app = angular.module('beamng.apps')


app.config(['$compileProvider', function($compileProvider) {

  // Allow additional URL patterns for img src attributes
  console.log($compileProvider.imgSrcSanitizationWhitelist())
  $compileProvider.imgSrcSanitizationWhitelist(/^\s*(https?|ftp|file|blob|local|mailto):|data:image\/(png|jpg|jpeg|gif|svg\+xml);/);}])

app.directive('nickel', [function () {
  return {
    templateUrl:  '/ui/modules/apps/Nickel/app.html',
    replace: true,
    restrict: 'EA',
    scope: true,
    controller: ['$scope', '$timeout', '$sce', function($scope, $timeout, $sce) {
  
        // Function to be called on page load 
      $scope.init = function($scope) { 
        $scope.hideCard = true
        $scope.hideAddRoles = true
        bngApi.engineLua('extensions.Nickel.initializeInterface(0)')
        setTimeout(function() {
            registerCustomEvents($scope);
        }, 1000);
        console.log("Angular calling client lua ...")


        }
  



      $scope.server_version = "Offline"

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
    $scope.$on('getServerValues', function (event, data) {
        console.log(data)
        $scope.nkserver_version = data.server_version

    });
    $scope.$on('getPlayers', function (event, data) {
      console.log(data)
      $scope.nkplayers = data
    });
    $scope.$on('getRoles', function (event, data) {
      console.log(data)
      $scope.nkroles = data.sort((a, b) => b.permlvl - a.permlvl); 
    });

    $scope.$on('SyncEnvironment', function (event, data) {
      $scope.game_temp = data.temperature
      $scope.game_gravity = data.gravity
      console.log(data.wind)
      $scope.game_wind = data.wind
      $scope.game_meteo = data.meteo
      if(parseInt(data.time[0],10)<10)data.time[0]='0'+data.time[0];
      if(parseInt(data.time[1],10)<10)data.time[1]='0'+data.time[1];
      $scope.game_time = data.time

      
    });
    $scope.$on('SyncWeatherPresets', function (event, data) {
      $scope.weatherPresets = data
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

    $scope.showPlayerCard = function(event, player) {
      const playerCard = document.querySelector(".player-card")
      const buttonRect = event.target.getBoundingClientRect(); 
      const playerCardParent = playerCard.parentElement.getBoundingClientRect();
      $scope.cardPlayer = player
      playerCard.style.top = `${(buttonRect.bottom - playerCardParent.top - 10) + playerCard.parentElement.scrollTop}px`;
      $scope.hideCard = false    

     
     
    };

    $scope.showAddRoles = function() {
      $scope.hideAddRoles = false  
    }

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
        search.value;
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
          console.log($scope[scopeVariable])
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
  


    function outsideClickListener(event) {
      // Vérifiez si le clic est en dehors de la player-card
      if (!event.target.classList.contains('nkplayer-button') && !event.target.classList.contains('player-card') && !document.querySelector(".player-card").contains(event.target)) {
          $scope.hideCard = true; // Ferme la player-card
          $scope.hideAddRoles = true; // Ferme la boîte de dialogue pour ajouter des rôles
          $scope.$apply();
      }
      else if (!document.querySelector(".add-roles-box").contains(event.target) && !document.querySelector(".add-icon").contains(event.target)) {
        $scope.hideAddRoles = true; // Ferme la boîte de dialogue pour ajouter des rôles
        $scope.$apply();
      }
    }
    document.addEventListener('click', outsideClickListener);

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

