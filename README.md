## Table of contents / Оглавление
 - [EN](#unified-interface-of-gamepad)
  1. [What is it](#what-is-it)
  2. [Version](#version)
  3. [Basic usage](#basic-usage)
  4. [Gamepads](#gamepads)
  5. [Gamepad2](#gamepad2)
 - [РУС](#Унифицированный-интерфейс-для-джойстиков)
  1. [О библиотеке](#Унифицированный-интерфейс-для-джойстиков)
  2. [Версия](#Версия)
  3. [Основное использование](#Основное-использование)
  4. [Gamepads](#gamepads-1)
  5. [Gamepad2](#gamepad2-1)


Unified interface of gamepad.
=========
What is it [↑](#table-of-contents--Оглавление)
---
Based on the GamepadAPI interface for gamepads. in broowser. Advantages:
  - Fixed association of buttons and sticks;
  - Logic blocks and structure of the gamepad;
  - Only the names of the elements;
  - Event-based system with the ability to use direct references to the values;
  - Flexible settings.

Version [↑](#table-of-contents--Оглавление)
----
0.0.1.beta

For compile using modifed  [coffeescript@1.7.1](https://github.com/NightMigera/coffeescript).
Basic coffeescript not allow preprocessor directive.

Basic usage: [↑](#table-of-contents--Оглавление)
-----------

Example:
```
  var game = new Game();        // Dumb game that needs a gamepad

  var gamepads = new Gamepads({
    silent: false,              // errors and warnings print to console
    naming: GAMEPAD_NAME_SHORT  // abbreviated names of blocks and elements (recommended)
  });

  gamepads.on('connect', function(e) {  // connect the gamepad handle events
    var pad = e.detail;                 // get object Gamepad2

    pad.on('off', function() {          // Processing disconnect from the game (dead, or fell off for other reasons)
      game.pause();
    }).on('on', function() {            // `on` returns a reference to the current object, so you can create a chain
      game.play();
    });

    pad.menu.back.on('press', function() {  // handle pressing
      game.toggleMenu();
    });

    pad.face.PR.on('down', function() { // handle action button
      game.jumpStart();
    }).on('up', function() {
      game.jumpEnd();
    });

    pad.axes.on('change', function(e) { // subscribe for all changes in block
      switch (e.target.name) {          // define named genus actions
        case 'LSX':
        case 'LSY':
          game.motion(e.target);
          break;
        case 'RSX':
        case 'RSY':
          game.view(e.target);
          break;
                                        // and clicking on the sticks are not processed
      }
    });

    // many gamepad can use triggers as an axis with smooth change of values
    if (pad.lrtb.LT.MODE === GAMEPAD_AXIS_AS_COMBINED) {
      pad.lrtb.LT.on('change', function (e) {
        game.bow.set(e.detail.newValue);
      });
    } else { // but if it is not, then at least let it be basic functionality
      pad.lrtb.LT.on('down', function () {
        game.bow.set(255);
      }).on('up', function (e) {
        game.bow.set(0);
      });
    }
    pad.face.TR.on('press', function() { // Х or ⬜ fire
      game.bow.fire();
    });
  });
```

In the global scope objects are declared:
 * `Gamepads` array of `Gamepad2`;
 * `Gamepad2` basic class of gamepad;
 * `GamepadMap` class to create their own mapping or correction of current;
 * `GAMEPAD_NAME_FULL`, `GAMEPAD_NAME_SHORT`, `GAMEPAD_AXIS_AS_STICK`, `GAMEPAD_AXIS_AS_BUTTON`,
   `GAMEPAD_AXIS_AS_COMBINED` constants that are discussed below.

Gamepads [↑](#table-of-contents--Оглавление)
---

When you create an object in the constructor can be passed to the config, as in the example above.

Configuration (by fully understanding why):
 * `silent: true` Silent mode no message is printed to the console
   Affects all objects `Gamepads`. If you compile a `debug` mode is ignored and counted as` false`;
 * `autoDetect: true` Are automatic detection and addition of a gamepad;
 * `frequencyUpdate: 60` The frequency of status updates in Hz;
 * `webkitFrequencyUpdate: 10` Frequency of updating the list of gamepads in webkit;
 * `webkitInactiveDisconnect: 90000` After some number of milliseconds count gamepad disconnected in webkit;
 * `naming: GAMEPAD_NAME_FULL | GAMEPAD_NAME_SHORT` bitmask that defines the style of naming buttons and blocks;
 * `maps: null` advanced mapping. Array of object `GamepadMap`;
 * `allowCustomBlockName: false` whether to allow their names to the blocks. Is considered to be in the extended block.

A *class* `Gamepads` have only one method:
 * `getInfo([String type])` returns an array of error messages and comments In accordance with the `type` or all at once.

*Object* `Gamepads`. Public methods and properties:
 * `registered` object with gamepads, registered in the system, the name matches the `id`, value is array of gamepads;
 * `config` the current configuration. `readOnly` Consequences of Changes is not predictable;
 * `detect()` method to obtain information about the gamepads and added to the array registered
   Returns `false` if the API is not supported. And `true` when the operation was successful;
 * `addEventListener()`, `removeEventListener()`, `dispatchEvent()` implements interface `EventTarget`;
 * `on()`, `off()`, alias for `addEventListener()` and `removeEventListener()`, respectively, but they return a reference to the current object;
 * `emet(String name[, Event evt])` fire event type `name` and call listeners passing them `evt`, if it exist;
 * `onconnect`, `ondisconnect`, `onadd` to handle events in the old style.

Events *object* `Gamepads`:
 * `connect` connect the gamepad. In the listener call is transferred to an object `CustomEvent` `Gamepad2` located in` customEvent.detail`, which was connected;
 * `disconnect` disconnect gamepad. The listener is called similarly to `connect` event;
 * `add` Event registration gamepad. Adding a connection does not mean! The function is called similarly to `connect` event.

Approx .: `Gamepad2` object in` Gamepads` events unfold as follows:
`add[, connect[, disconnect[, ...]]`.

Gamepad2 [↑](#table-of-contents--Оглавление)
---

The main interface for the gamepad. Do the buttons have a press events, and in the sticks - changes.
Buttons and blocks are separated into logical units (in brackets the name in full name):
 * `dpad` — D-pad (`dPad`)
   - `up` up
   - `dpwn` down
   - `left` left
   - `right` right (Your CO)
 * `lrtb` — upper triggers and shoulders (buttons R1 L1 R2 L2 in PS notation) (`shouldersTriggers`)
   - `LT` button LT or L1 (`leftTrigger`) maybe trigger
   - `RT` button RT or R1 (`rightTrigger`) maybe trigger
   - `LB` button LB or L2 (`leftShoulder`)
   - `RB` button RB or R2 (`rightShoulder`)
 * `menu` — menu button in the center
   - `back` Back or Select, in rare cases, it may not be
   - `start` Start or Forward, in rare cases, it may not be
   - `home` Home or Meta, optional
 * `axes` — sticks and buttons of stick. Down and to the right — a positive value, up and to the left — negative
   - `LSB` button of the left stick (`leftStickButton`)
   - `LSX` position of the left stick on the X axis
   - `LSY` on the Y axis
   - `RSB` button of the right stick (`rightStickButton`)
   - `RSX` position of the right stick on the X axis
   - `RSY` on the Y axis
 * `face` — button on the right
   - `PR` bottom button (`A` by XBox or `❌` by PS) (`primary`)
   - `SC` right button (`B` or `◯`) (`secondary`)
   - `TR` left button  (`X` or `⬜`) (`tertiary`)
   - `QT` upper button (`Y` or `△`) (`quaternary`)

Configuration (default is translated from `Gamepads`):
 * `naming: GAMEPAD_NAME_FULL | GAMEPAD_NAME_SHORT` bitmask title blocks and buttons
   If the mask contains `GAMEPAD_NAME_FULL`, then the full names of some units and buttons;
 * `maps: null` advanced mapping. Array of object `GamepadMap`,
   `vendor`,  `prodict` and `platform` should match that mapping was applied;
 * `allowCustomBlockName: false` whether to allow their names to the blocks. Is considered to be in the extended block;
 * `trusted: false` Not to check the correctness of the configuration should be set `true`.

Do not have a *class* `Gamepad2` its public methods and properties.

Public methods and properties *object* `Gamepad2`:
 * `connected` gamepad is plugged;
 * `gamepad` reference to original `Gamepad`;
 * `map` current mapping;
 * `config` (`readOnly`) current configuration;
 * `dpad`, `lrtb`, `menu`, `axes`, `face` blocks described above;
 * `getMap(String id)` parses the `id`, sets him on` GamepadMap` and returns it;
 * `reMap(GamepadMap map)` overrides the current mapping of the new `map` forcibly;
 * `connect()` according to the object that the gamepad is connected;
 * `disconnect()` according to the object that the gamepad is disconnected;
 * `poke()` call status polling;
 * installing, removing, and calling listeners are equally `Gamepads`.

Events of *object* `Gamepad2` and him elements:
 * `change` have all elements and blocks at the object, is passed to the listener `CustomEvent`,
   stating that` detail.target` (object reference element) changed state from `detail.oldValue` on` detail.newValue`;
     - In `gamepad2` signs all blocks and all items returned are changing;
     - In `block` subscribe all block elements;
     - In `axis`,` button`. Mode is indicated in the `MODE`:
       * In `GAMEPAD_AXIS_AS_BUTTON` (default mode) is called when the press,
         `oldValue` meets old value `pressed`, and `newValue` - new;
       * In `GAMEPAD_AXIS_AS_STICK` and `GAMEPAD_AXIS_AS_COMBINED` called when the value changes.
         Relevance to the hammers (triggers) on some models;
  * `on`, only` gamepad2`, reports that the joystick connected. To the listener passed `null`;
  * `off`, only` gamepad2`, reports that the joystick disconnected. To the listener passed `null`;
  * `down`,` up`, `press` only buttons, similar to keyboard buttons, but the listener is passed `null`:
   - `down` button is pressed;
   - `up` button is released;
   - `press` button was pressed and released.

Controls (block, button, axis):
 * For all the elements characteristic:
   - installing, removing, and calling listeners are equally `Gamepads`;
   - `parent` property, parent of the element;
   - `name` property, the name of the element;
 * Properties and methods inherent elements `button` and` axis`:
   - `MODE` property, bitmask, values: `GAMEPAD_AXIS_AS_BUTTON`, `GAMEPAD_AXIS_AS_STICK`, summary ` GAMEPAD_AXIS_AS_COMBINED`;
 * If `MODE` contains `GAMEPAD_AXIS_AS_STICK`:
   - `value` property of the current value from 0 to 255. change automatically with the change of the real state;
 * If `MODE` contains `GAMEPAD_AXIS_AS_BUTTON`:
   - `pressed` the current value of the property if you pressed. Changes, as well automatically.

----------------------

Унифицированный интерфейс для джойстиков. [↑](#table-of-contents--Оглавление)
=========

Основанный на GamepadAPI интерфейс для джойстиков. Преимущества:
  - Фиксированная ассоциация кнопок и движков;
  - Логические блоки и структура джойстика;
  - Только имена элементов, без массива и номеров;
  - Событийно-ориентированная система с возможностью использовать прямые обращения к значениям;
  - Возможность гибкой настройки;

Версия [↑](#table-of-contents--Оглавление)
----
0.0.1.бета

Для компиляции испоользуется модифицированная версия [coffeescript@1.7.1](https://github.com/NightMigera/coffeescript)
с препроцессором и инклюдами.

Основное использование: [↑](#table-of-contents--Оглавление)
----

Пример:
```
  var game = new Game();        // некотрая игра, которой и нужен джойстик
  
  var gamepads = new Gamepads({
    silent: false,              // ошибки и сообщения пишем в консоль
    naming: GAMEPAD_NAME_SHORT  // наименования блоков и элементов сокращённые (рекоммендуется)
  });
  
  gamepads.on('connect', function(e) {  // обрабатываем событие подключения джойстика
    var pad = e.detail;                 // получаем объект Gamepad2
    
    pad.on('off', function() {          // обработка отключения от игры (разрядился, или отвалился по другим причинам)
      game.pause();
    }).on('on', function() {            // `on` возвращает ссылку на текущий объект, так что можно творить цепочку
      game.play();
    });
    
    pad.menu.back.on('press', function() {  // обрабатываем нажатие на кнопку
      game.toggleMenu();
    });
    
    pad.face.PR.on('down', function() { // работа главной экшн-кнопки
      game.jumpStart();
    }).on('up', function() {
      game.jumpEnd();
    });
    
    pad.axes.on('change', function(e) { // подписываемся на все изменения в блоке
      switch (e.target.name) {          // определяем по имени род действия 
        case 'LSX':
        case 'LSY':
          game.motion(e.target);
          break;
        case 'RSX':
        case 'RSY':
          game.view(e.target);
          break;
                                        // а нажатия на стики не обрабатываются
      }
    });
    
    // во многих джойстиках можно использовать курки, как оси, с плавным изменением значения
    if (pad.lrtb.LT.MODE === GAMEPAD_AXIS_AS_COMBINED) { 
      pad.lrtb.LT.on('change', function (e) {
        game.bow.set(e.detail.newValue);
      });
    } else { // но если это не так, то хоть базовый функционал пусть будет
      pad.lrtb.LT.on('down', function () {
        game.bow.set(255);
      }).on('up', function (e) {
        game.bow.set(0);
      });
    }
    pad.face.TR.on('press', function() { // Х или ⬜ стрелять, как обычно
      game.bow.fire();
    });
  });
```

В глобальной области видимости появляются объекты:
 * `Gamepads` массив джойстиков `Gamepad2`
 * `Gamepad2` класс джойстиков, с которым работаем
 * `GamepadMap` класс для создания собственных ассоциаций или исправления текущих
 * `GAMEPAD_NAME_FULL`, `GAMEPAD_NAME_SHORT`, `GAMEPAD_AXIS_AS_STICK`, `GAMEPAD_AXIS_AS_BUTTON`, `GAMEPAD_AXIS_AS_COMBINED` константы, будут рассмотрены ниже.
  
Gamepads [↑](#table-of-contents--Оглавление)
---
  
При создании объекта в конструктор может быть передан конфиг, как в примере выше.

Конфигурация (задавать при реальной необходимости)):
 * `silent: true` В тихом режиме не печатает сообщения в консоль. Влияет на все объекты `Gamepads`. Если скомпилировать в `debug` режиме, то игнорируется и считается за `false`.
 * `autoDetect: true` Включить ли автоматическое определение и добавление джойстиков?
 * `frequencyUpdate: 60` Частота обновления состояния в Гц
 * `webkitFrequencyUpdate: 10` Частота обновления списка джойстиков в webkit
 * `webkitInactiveDisconnect: 90000` Через какое количество миллисекунд считать джойстик отключенным в webkit
 * `naming: GAMEPAD_NAME_FULL | GAMEPAD_NAME_SHORT` маска, определяющая стиль именования кнопок и блоков.
 * `maps: null` дополнительные ассоциации. Массив объектов `GamepadMap`.
 * `allowCustomBlockName: false` допускать ли свои имена блоков. Рассмотрено будет в расширенном блоке.

У *класса* `Gamepads` всего один метод:
 * `getInfo([String type])` возвращает массив ошибок, замечаний и сообщений в соотвествии с `type` или все сразу.
 
*Объект* `Gamepads`. Общедоступные методы и параметры:
 * `registered` объект, с джойстиками, зарегистрированными в системе, имя совпадает с `id`, в значении массив джойстиков
 * `config` текущая конфигурация. `readOnly` Последствия правки не предсказуемы.
 * `detect()` метод, получающий сведения о джойстиках и добавляющий в массив незарегестрированные. Возвращает `false` если API не поддерживается. И `true` когда операция прошла успешно.
 * `addEventListener()`, `removeEventListener()`, `dispatchEvent()` в соответсвии с интерфейсом `EventTarget`
 * `on()`, `off()`, синонимы для `addEventListener()` и `removeEventListener()` соответственно, но возвращают ссылку на текущий объект.
 * `emet(String name[, Event evt])` вызывает действие с типом `name` и передаёт в слушателей `evt`, если он задан.
 * `onconnect`, `ondisconnect`, `onadd` для обработки событий в старом стиле.

События *объекта* `Gamepads`:
 * `connect` подключение джойстика. В вызываемую функцию передаётся CustomEvent с объектом `Gamepad2` находямщемся в `customEvent.detail`, который и был подключен.
 * `disconnect` отключение джойстика. Функция вызывается аналогично `connect` событию.
 * `add` событие регистрации джойстика. Добавление не означает включение! Функция вызывается аналогично `connect` событию. 

Прим.: для объекта `Gamepad2` в `Gamepads` события разворачиваются следующим образом: 
`add[, connect[, disconnect[, ...]]`.

Gamepad2 [↑](#table-of-contents--Оглавление)
----

Основной интерфейс для джойстика. У кнопок есть события нажатия, а у стиков — изменения.
Кнопки и блоки разнесены по логическим блокам (в скобочках названия в режиме полных имён):
 * `dpad` — крестовина (`dPad`)
   - `up` вверх
   - `dpwn` вниз
   - `left` влево
   - `right` вправо
 * `lrtb` — верхние тригерр и бампер (кнопки R1 L1 R2 L2 в нотации PS) (`shouldersTriggers`)
   - `LT` кнопка LT или L1 (`leftTrigger`) может быть рычагом
   - `RT` кнопка RT или R1 (`rightTrigger`) может быть рычагом
   - `LB` кнопка LB или L2 (`leftShoulder`)
   - `RB` кнопка RB или R2 (`rightShoulder`)
 * `menu` — кнопки меню в центре
   - `back` Back или Select, в редких случаях может не быть
   - `start` Start или Forward, в редких случаях может не быть
   - `home` Home или Meta, опциональная
 * `axes` — стики и кнопки стиков. Вниз и вправо — положительное значение, вверх и влево — отрицательные
   - `LSB` кнопка левого движка (`leftStickButton`)
   - `LSX` положение левого движка на оси Х
   - `LSY` по оси Y
   - `RSB` кнопка правого движка (`rightStickButton`)
   - `RSX` положение правого движка по оси Х
   - `RSY` по оси Y
 * `face` — кнопки справа
   - `PR` нижняя кнопка (`A` в XBox или `❌` в PS) (`primary`)
   - `SC` правая кнопка (`B` или `◯`) (`secondary`)
   - `TR` левая кнопка  (`X` или `⬜`) (`tertiary`)
   - `QT` верхняя кнопка (`Y` или `△`) (`quaternary`)

Конфигурация (по умолчанию транслируется из `Gamepads`)
 * `naming: GAMEPAD_NAME_FULL | GAMEPAD_NAME_SHORT` битовая маска названия блоков и кнопок. 
 Если маска содержит `GAMEPAD_NAME_FULL`, то названия некоторых блоков и кнопок полные.
 * `maps: null` если не `null` является массивом объектов `GamepadMap`, в которых указаны `vendor`,  `prodict` и `platform`, которые определяют применимость карты только при полном совпадении. 
 * `allowCustomBlockName: false` допускать ли свои имена блоков. 
 * `trusted: false` Чтобы не проверять правильность конфигурации, следует установить `true`

У *класса* `Gamepad2` нет своих доступных методов и свойств.

Общедоступные методы и свойства *объекта* `Gamepad2`:
 * `connected` подключен ли джойстик
 * `gamepad` ссылка на оригинальный `Gamepad`
 * `map` текущая карта ассоциаций
 * `config` (`readOnly`) текущая конфигурация
 * `dpad`, `lrtb`, `menu`, `axes`, `face` блоки, описанные выше
 * `getMap(String id)` разбирает `id`, устанавливает по нему `GamepadMap` и возвращает её.
 * `reMap(GamepadMap map)` переопределяет текущую ассоциацию на новую из `map` принудительно.
 * `connect()` сообщает объекту, что джойстик подключен.
 * `disconnect()` сообщает объекту, что джойстик отключен
 * `poke()` вызвать опрос состояния
 * установка, удаление и вызов функций-слушателей идиентично `Gamepads`
  
События *объекта* `Gamepad2` и его элементов.
 * `change` есть у всех элементов управления, блоков и у самого объекта, в функцию передаётся `CustomEvent`, в котором сообщается, что `detail.target` (ссылка на объект элеманта) изменил состояние с `detail.oldValue` на `detail.newValue`.
  - В `gamepad2` подписывает все блоки и все элементы возвращать изменения.
  - В `block` подписывает все элементы блока
  - В `axis`, `button`. Режим указывается в `MODE`.
    * В режиме `GAMEPAD_AXIS_AS_BUTTON` (режим по умолчанию) вызывается при изменении нажатия, `oldValue` соотвествует старому значению `pressed`, а `newValue` — новому. 
    * В режиме `GAMEPAD_AXIS_AS_STICK` и `GAMEPAD_AXIS_AS_COMBINED` вызывается при изменении значения. Актуальн для курков (триггеров) на некоторых моделях
 * `on`, только у `gamepad2`, сообщает, что джойстик включился. В функцию передаётся `null`
 * `off`, только у `gamepad2`, сообщает, что джойстик отключился. В функцию передаётся `null`
 * `down`, `up`, `press` только у кнопок, аналогично клавиатурным кнопкам, но в функцию передаётся `null`.
  - `down` кнопка нажата
  - `up` кнопка отпущена
  - `press` кнопка была нажа и отпущена
   
Элементы управления (блок, кнопка, ось):
 * Для всех элементов присущи:
   - установка, удаление и вызов функций-слушателей идиентично `Gamepads`
   - `parent` свойство, родительский элемент (блок)
   - `name` свойство, название элемента
 * Свойства и методы, присущие элементам `button` и `axis`:
   - `MODE` свойство, маска режима работы
 * Если `MODE` содержит `GAMEPAD_AXIS_AS_STICK`
   - `value` свойство текущее значение от 0 до 255. Меняется автоматически с изменением реального состояния.
 * Если `MODE` содержит `GAMEPAD_AXIS_AS_BUTTON`
   - `pressed` свойство текущее значение нажата ли кнопка. Меняется, так же, автоматически.

License
----
GPL v2

