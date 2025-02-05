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

	Команда.Опция("s src", "", "копируемые файлы")
	       .ТСтрока()
	       .Обязательный()
	       .ВОкружении("CPDB_FILE_COPY_SRC");
	
	Команда.Опция("d dst", "", "каталог приемник")
	       .ТСтрока()
	       .Обязательный()
	       .ВОкружении("CPDB_FILE_COPY_DST");
	
	Команда.Опция("m move delsrc", Ложь, "выполнить перемещение файлов (удалить источник после копирования)")
	       .Флаговый()
	       .ВОкружении("CPDB_FILE_COPY_MOVE");
	
	Команда.Опция("l lastonly", Ложь, "копирование файлов, измененных не ранее текущей даты (параметр /D для xcopy)")
	       .Флаговый()
	       .ВОкружении("CPDB_FILE_COPY_LAST_ONLY");

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

	Источник        = ЧтениеОпций.ЗначениеОпции("src");
	Приемник        = ЧтениеОпций.ЗначениеОпции("dst");
	Перемещение     = ЧтениеОпций.ЗначениеОпции("move");
	ТолькоСегодня   = ЧтениеОпций.ЗначениеОпции("lastonly");

	РаботаСФайлами.КомандаСистемыКопироватьФайл(Источник,
	                                            Приемник,
	                                            Перемещение,
	                                            ТолькоСегодня);

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
