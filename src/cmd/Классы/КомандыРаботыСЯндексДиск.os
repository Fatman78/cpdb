// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/cpdb/
// ----------------------------------------------------------

// Процедура - устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект описание команды
//
Процедура ОписаниеКоманды(Команда) Экспорт

	Команда.ДобавитьКоманду("put p",
	                        "поместить файл на Yandex-диск",
	                        Новый КомандаПоместитьФайлВЯДиск());

	Команда.ДобавитьКоманду("get g",
	                        "скачать файл с Yandex-диска",
	                        Новый КомандаПоместитьФайлВЯДиск());

	Команда.Опция("t yt token ya-token", "", "Token авторизации для Yandex-диска")
	       .ТСтрока()
	       .Обязательный()
	       .ВОкружении("CPDB_YD_TOKEN");

КонецПроцедуры // ОписаниеКоманды()
