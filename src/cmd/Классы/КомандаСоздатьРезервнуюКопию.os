// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/cpdb/
// ----------------------------------------------------------

#Использовать "../../core"

Перем Лог;       // - Объект      - объект записи лога приложения

#Область СлужебныйПрограммныйИнтерфейс

// Процедура - устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект описание команды
//
Процедура ОписаниеКоманды(Команда) Экспорт
	
	Команда.Опция("pp params", "", "Файлы JSON содержащие значения параметров,
	                               | могут быть указаны несколько файлов разделенные "";""")
	       .ТСтрока()
	       .ВОкружении("CPDB_PARAMS");

	Команда.Опция("d db sql-db", "", "имя базы для резервного копирования")
	       .ТСтрока()
	       .Обязательный()
	       .ВОкружении("CPDB_SQL_DATABASE");
	
	Команда.Опция("p bak-path", "", "путь к файлу резервной копии")
	       .ТСтрока()
	       .Обязательный()
	       .ВОкружении("CPDB_SQL_BACKUP_PATH");
	
КонецПроцедуры // ОписаниеКоманды()

// Процедура - запускает выполнение команды устанавливает описание команды
//
// Параметры:
//  Команда    - КомандаПриложения     - объект  описание команды
//
Процедура ВыполнитьКоманду(Знач Команда) Экспорт

	ЧтениеОпций = Новый ЧтениеОпцийКоманды(Команда);

	ВыводОтладочнойИнформации = ЧтениеОпций.ЗначениеОпции("verbose");

	ПараметрыСистемы.УстановитьРежимОтладки(ВыводОтладочнойИнформации);

	Сервер              = ЧтениеОпций.ЗначениеОпции("srvr", Истина);
	Пользователь        = ЧтениеОпций.ЗначениеОпции("user", Истина);
	ПарольПользователя  = ЧтениеОпций.ЗначениеОпции("pwd", Истина);
	База                = ЧтениеОпций.ЗначениеОпции("db");
	ПутьКРезервнойКопии = ЧтениеОпций.ЗначениеОпции("bak-path");

	ПодключениеКСУБД = Новый ПодключениеMSSQL(Сервер, Пользователь, ПарольПользователя);
	
	РаботаССУБД = Новый РаботаССУБД(ПодключениеКСУБД);

	РаботаССУБД.ВыполнитьРезервноеКопирование(База, ПутьКРезервнойКопии);

КонецПроцедуры // ВыполнитьКоманду()

#КонецОбласти // СлужебныйПрограммныйИнтерфейс

#Область ОбработчикиСобытий

// Процедура - обработчик события "ПриСозданииОбъекта"
//
// BSLLS:UnusedLocalMethod-off
Процедура ПриСозданииОбъекта()

	Лог = ПараметрыСистемы.Лог();

КонецПроцедуры // ПриСозданииОбъекта()
// BSLLS:UnusedLocalMethod-on

#КонецОбласти // ОбработчикиСобытий
