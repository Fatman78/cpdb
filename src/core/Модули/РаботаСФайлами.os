// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/cpdb/
// ----------------------------------------------------------

#Использовать yadisk
#Использовать nextcloud-lib
#Использовать fs
#Использовать 1commands

Перем Лог;           // - Объект    - объект записи лога приложения

#Область ПрограммныйИнтерфейс

// Функция, выполняет копирование/перемещение указанных файлов с использованием команд системы (xcopy)
//
// Параметры:
//   Источник           - Строка       - копируемые файлы
//   Приемник           - Строка       - назначение копирования, каталог или файл
//   Перемещение        - Булево       - выполнить перемещение файлов (удалить источник после копирования)
//   ТолькоСегодня      - Булево       - копирование файлов, измененных не ранее текущей даты (параметр /D для xcopy)
//
Процедура КомандаСистемыКопироватьФайл(Источник,
                                       Приемник,
                                       Перемещение = Ложь,
                                       ТолькоСегодня = Ложь) Экспорт

	ВремФайл = Новый Файл(Приемник);

	Лог.Информация("Начало копирования файла ""%1"" -> ""%2""", Источник, Приемник);

	Если НЕ ВремФайл.Существует() Тогда
		ФС.ОбеспечитьКаталог(Приемник);
	КонецЕсли;
	Если НЕ ВремФайл.ЭтоКаталог() Тогда
		Лог.Ошибка("Необходимо указать каталог в качестве приемника ""%1""", Приемник);
	КонецЕсли;

	КомандаРК = Новый Команда;
	
	КомандаРК.УстановитьКоманду("xcopy");
	КомандаРК.ДобавитьПараметр(КомандаРК.ОбернутьВКавычки(Источник));
	КомандаРК.ДобавитьПараметр(КомандаРК.ОбернутьВКавычки(Приемник));
	КомандаРК.ДобавитьПараметр("/F");
	КомандаРК.ДобавитьПараметр("/J");
	КомандаРК.ДобавитьПараметр("/V");
	КомандаРК.ДобавитьПараметр("/Y");
	КомандаРК.ДобавитьПараметр("/Z");
	Если ТолькоСегодня Тогда
		лТекДата = ТекущаяДата();
		лФорматированнаяДата = Строка(Формат(лТекДата, "ДФ=MM-dd-yyyy"));
		КомандаРК.ДобавитьПараметр("/D:" + лФорматированнаяДата);
	КонецЕсли;

	КомандаРК.УстановитьИсполнениеЧерезКомандыСистемы(Ложь);
	КомандаРК.ПоказыватьВыводНемедленно(Ложь);
	
	КодВозврата = КомандаРК.Исполнить();

	ОписаниеРезультата = КомандаРК.ПолучитьВывод();
	
	Если КодВозврата = 0 Тогда
		Лог.Информация("Скопирован файл ""%1"" -> ""%2""", Источник, Приемник);
	Иначе
		ТекстОшибки = СтрШаблон("Ошибка копирования файла ""%1"" -> ""%2"", код возврата %3:%4%5",
		                        Источник,
		                        Приемник,
		                        КодВозврата,
		                        Символы.ПС,
		                        ОписаниеРезультата);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	Если Перемещение Тогда
		КомандаСистемыУдалитьФайл(Источник);
	КонецЕсли;

КонецПроцедуры // КомандаСистемыКопироватьФайл()

// Функция, выполняет удаление указанных файлов с использованием команды системы (del)
//   
// Параметры:
//   ПутьКФайлу             - Строка         - путь к удаляемому файлы
//   ИсключениеПриОшибке    - Строка         - Истина - вызывать исключение при ошибке удаления
//
Процедура КомандаСистемыУдалитьФайл(ПутьКФайлу, ИсключениеПриОшибке = Ложь) Экспорт

	Лог.Информация("Начало удаления файла ""%1""", ПутьКФайлу);

	КомандаРК = Новый Команда;
	
	КомандаРК.УстановитьКоманду("del");
	КомандаРК.ДобавитьПараметр("/F ");
	КомандаРК.ДобавитьПараметр("/Q ");
	КомандаРК.ДобавитьПараметр(ПутьКФайлу);

	КомандаРК.УстановитьИсполнениеЧерезКомандыСистемы(Ложь);
	КомандаРК.ПоказыватьВыводНемедленно(Ложь);
	
	КодВозврата = КомандаРК.Исполнить();

	ОписаниеРезультата = КомандаРК.ПолучитьВывод();
	
	Если Не ПустаяСтрока(ОписаниеРезультата) Тогда
		Лог.Информация("Вывод команды удаления: " + ОписаниеРезультата);
	КонецЕсли;

	Если КодВозврата = 0 Тогда
		Лог.Информация("Удален файл ""%1""", ПутьКФайлу);
	Иначе
		ТекстОшибки = СтрШаблон("Ошибка удаления файла ""%1"", код возврата %2: %3%4",
		                        ПутьКФайлу,
		                        КодВозврата,
		                        Символы.ПС,
		                        ОписаниеРезультата);
		Если ИсключениеПриОшибке Тогда
			ВызватьИсключение ТекстОшибки;
		Иначе
			Лог.Ошибка(ТекстОшибки);
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры // КомандаСистемыУдалитьФайл()

// Функция читает список файлов из файла
//
// Параметры:
//   ПутьКСписку                    - Строка    - путь к файлу со списком файлов архива
//   ДобавитьПутьКИсходномуФайлу    - Строка    - Истина - при чтении добавлять к результату
//                                                путь к исходному файлу списка
//   ДобавитьИсходныйФайл           - Строка    - Истина - добавить исходный файл в список
//
// Возвращаемое значение:
//   Массив из Строка    - список файлов архива
//
Функция ПрочитатьСписокФайлов(ПутьКСписку, ДобавитьПутьКИсходномуФайлу = Ложь, ДобавитьИсходныйФайл = Ложь) Экспорт

	ДлинаХеша = 32;

	ДанныеИсхФайла = Новый Файл(ПутьКСписку);

	МассивФайловЧастей = Новый Массив();
	
	ЧтениеСписка = Новый ЧтениеТекста(ПутьКСписку, КодировкаТекста.UTF8);
	СтрокаСписка = СокрЛП(ЧтениеСписка.ПрочитатьСтроку());
	Пока СтрокаСписка <> Неопределено Цикл
		Если ЗначениеЗаполнено(СтрокаСписка) Тогда
			ЧастиСтрокиФайла = СтрРазделить(СтрокаСписка, " ", Ложь);
			ИмяФайла = "";
			Для й = 0 По ЧастиСтрокиФайла.ВГраница() Цикл
				Если й = ЧастиСтрокиФайла.ВГраница() И СтрДлина(ЧастиСтрокиФайла[й]) = ДлинаХеша Тогда
					Прервать;
				КонецЕсли;
				ИмяФайла = ИмяФайла + ЧастиСтрокиФайла[й];
			КонецЦикла;
			Если ДобавитьПутьКИсходномуФайлу Тогда
				МассивФайловЧастей.Добавить(ДанныеИсхФайла.Путь + ИмяФайла);
			Иначе
				МассивФайловЧастей.Добавить(ИмяФайла);
			КонецЕсли;
		КонецЕсли;
		
		СтрокаСписка = СокрЛП(ЧтениеСписка.ПрочитатьСтроку());
	КонецЦикла;
		
	ЧтениеСписка.Закрыть();

	Если ДобавитьИсходныйФайл Тогда
		МассивФайловЧастей.Добавить(?(ДобавитьПутьКИсходномуФайлу, ДанныеИсхФайла.ПолноеИмя, ДанныеИсхФайла.Имя));
	КонецЕсли;

	Возврат МассивФайловЧастей;

КонецФункции // ПрочитатьСписокФайлов()

// Выполняет архиваци указанного файла с разбитием на части указанного размера
//   
// Параметры:
//   ПутьКФайлу          - Строка    - путь к файлу, который будет архивироваться
//   ИмяАрхива           - Строка    - имя файла-архива
//   ИмяСпискаФайлов     - Строка    - имя файла-списка (содержащего все чати архива)
//   РазмерТома          - Строка    - размер части {<g>, <m>, <b>} (по умолчанию 50m)
//   СтепеньСжатия       - Число     - уровень сжатия частей архива {0 - 9} (по умолчанию 0 - не сжимать)
//   УдалитьИсточник     - Булево    - Истина - после архивации исходный файл будет удален
//
// Возвращаемое значение:
//   Число    - количество файлов архива
//
Функция ЗапаковатьВАрхив(Знач ПутьКФайлу,
                         Знач ИмяАрхива,
                         Знач ИмяСпискаФайлов,
                         Знач РазмерТома = Неопределено,
                         Знач СтепеньСжатия = 0,
                         Знач УдалитьИсточник = Ложь) Экспорт

	ПутьКАрхиватору = НайтиАрхиватор();
	
	Если НЕ ЗначениеЗаполнено(ПутьКАрхиватору) Тогда
		ТекстОшибки = СтрШаблон("Ошибка архивации файла ""%1"": архиватор (7-Zip) не найден",
		                        ПутьКФайлу);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	ДанныеИсхФайла = Новый Файл(ПутьКФайлу);

	Если ЗначениеЗаполнено(ИмяАрхива) Тогда
		ПутьКАрхиву = ИмяАрхива;
	Иначе
		ПутьКАрхиву = ОбъединитьПути(ДанныеИсхФайла.Путь, ДанныеИсхФайла.ИмяБезРасширения + ".7z");
	КонецЕсли;
	Если НЕ ЗначениеЗаполнено(ИмяСпискаФайлов) Тогда
		ИмяСпискаФайлов = ОбъединитьПути(ДанныеИсхФайла.Путь, ДанныеИсхФайла.ИмяБезРасширения + ".split");
	КонецЕсли;

	Лог.Информация("Начало разбиения файла ""%1"" на части по %2", ПутьКФайлу, РазмерТома);

	КомандаРК = Новый Команда();
	
	КомандаРК.УстановитьКоманду(ПутьКАрхиватору);
	КомандаРК.ДобавитьПараметр("a");
	КомандаРК.ДобавитьПараметр(КомандаРК.ОбернутьВКавычки(ПутьКАрхиву));
	КомандаРК.ДобавитьПараметр(КомандаРК.ОбернутьВКавычки(ПутьКФайлу));
	КомандаРК.ДобавитьПараметр("-t7z");

	Если ЗначениеЗаполнено(РазмерТома) Тогда
		КомандаРК.ДобавитьПараметр(СтрШаблон("-v%1", РазмерТома));
	Иначе
		КомандаРК.ДобавитьПараметр("-v50m");
	КонецЕсли;

	Если ЗначениеЗаполнено(СтепеньСжатия) Тогда
		КомандаРК.ДобавитьПараметр(СтрШаблон("-mx%1", СтепеньСжатия));
	Иначе
		КомандаРК.ДобавитьПараметр("-mx0");
	КонецЕсли;

	КомандаРК.УстановитьИсполнениеЧерезКомандыСистемы(Ложь);
	КомандаРК.ПоказыватьВыводНемедленно(Ложь);
	
	КодВозврата = КомандаРК.Исполнить();

	ОписаниеРезультата = КомандаРК.ПолучитьВывод();

	Если КодВозврата = 0 Тогда
		Если УдалитьИсточник Тогда
			КомандаСистемыУдалитьФайл(ПутьКФайлу);
		КонецЕсли;
		КоличествоЧастей = СоздатьСписокФайлов(ПутьКАрхиву, ИмяСпискаФайлов);
		Лог.Информация("Выполнено разбиение файла ""%1"" на %2 частей по %3", ПутьКФайлу, КоличествоЧастей, РазмерТома);
		Возврат КоличествоЧастей;
	Иначе
		ТекстОшибки = СтрШаблон("Ошибка разбиения файла ""%1"", код возврата %2:%3%4",
		                        ПутьКФайлу,
		                        КодВозврата,
		                        Символы.ПС,
		                        ОписаниеРезультата);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

КонецФункции // ЗапаковатьВАрхив()

// Процедура, выполняет распаковку архива
//   
// Параметры:
//   ПутьКАрхиву         - Строка    - путь к файлу архива, который будет распаковываться
//   ЭтоСписокФайлов     - Булево    - Истина - передан список файлов;
//                                     Ложь - передан первый том архива
//   УдалитьИсточник     - Булево    - Истина - после распаковки исходный файл будет удален
//
Процедура РаспаковатьАрхив(Знач ПутьКАрхиву, Знач ЭтоСписокФайлов = Ложь, Знач УдалитьИсточник = Ложь) Экспорт

	ПутьКАрхиватору = НайтиАрхиватор();

	Если НЕ ЗначениеЗаполнено(ПутьКАрхиватору) Тогда
		ТекстОшибки = СтрШаблон("Ошибка распаковки архива ""%1"": архиватор (7-Zip) не найден",
		                        ПутьКАрхиву);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	ДанныеИсхФайла = Новый Файл(ПутьКАрхиву);

	МассивФайловЧастей = Новый Массив();

	Если ЭтоСписокФайлов Тогда
		МассивФайловЧастей = ПрочитатьСписокФайлов(ПутьКАрхиву, Истина, Истина);
		ПерваяЧастьАрхива = МассивФайловЧастей[0];
	Иначе
		ПерваяЧастьАрхива = ПутьКАрхиву;
		МассивФайловЧастей = НайтиФайлы(ДанныеИсхФайла.Путь, ДанныеИсхФайла.ИмяБезРасширения + ".???", Ложь);
	КонецЕсли;

	Лог.Отладка("Всего частей: " + МассивФайловЧастей.Количество());

	Лог.Информация("Начало распаковки из архива ""%1""", ПерваяЧастьАрхива);

	КомандаРК = Новый Команда();
	
	КомандаРК.УстановитьКоманду(ПутьКАрхиватору);
	КомандаРК.ДобавитьПараметр("x");
	КомандаРК.ДобавитьПараметр("-aoa");
	КомандаРК.ДобавитьПараметр("-y");
	КомандаРК.ДобавитьПараметр(СтрШаблон("-o%1", ДанныеИсхФайла.Путь));
	КомандаРК.ДобавитьПараметр(ПерваяЧастьАрхива);

	КомандаРК.УстановитьИсполнениеЧерезКомандыСистемы(Ложь);
	КомандаРК.ПоказыватьВыводНемедленно(Ложь);
	
	КодВозврата = КомандаРК.Исполнить();

	ОписаниеРезультата = КомандаРК.ПолучитьВывод();

	Если КодВозврата = 0 Тогда
		Если УдалитьИсточник Тогда
			Для Каждого ФайлЧасти Из МассивФайловЧастей Цикл
				Если ТипЗнч(ФайлЧасти) = Тип("Файл") Тогда
					КомандаСистемыУдалитьФайл(ФайлЧасти.ПолноеИмя);
				Иначе
					КомандаСистемыУдалитьФайл(ФайлЧасти);
				КонецЕсли;
			КонецЦикла;
		КонецЕсли;
		Лог.Информация("Распакован архив ""%1""", ПерваяЧастьАрхива);
	Иначе
		ТекстОшибки = СтрШаблон("Ошибка распаковки архива ""%1"", код возврата %2:%3%4",
		                        ПерваяЧастьАрхива,
		                        КодВозврата,
		                        Символы.ПС,
		                        ОписаниеРезультата);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

КонецПроцедуры // РаспаковатьАрхив()

// Создает папку на Я-Диске
//
// Параметры:
//   ЯДиск          - ЯндексДиск    - объект ЯндексДиск для работы с yandex-диском
//   ЦелевойПуть    - ЯндексДиск    - путь на yandex-диске к создаваемому каталогу
//
// Возвращаемое значение:
//   Строка    - Созданный путь
//
Функция СоздатьПапкуНаЯДиске(ЯДиск, Знач ЦелевойПуть) Экспорт

	КаталогНайден = Ложь;
	Попытка
		СвойстваПапки = ЯДиск.ПолучитьСвойстваРесурса(ЦелевойПуть);
		КаталогНайден = Истина;
	Исключение
		СвойстваПапки = Новый Структура("type", "dir");
	КонецПопытки;

	Если СвойстваПапки["type"] <> "dir" Тогда
		ТекстОшибки = СтрШаблон("Ошибка при создании папки  Яндекс-Диска: %1", ЦелевойПуть);
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;

	ТекущийПуть = "";
	Если НЕ КаталогНайден Тогда
		Попытка
			ЯДиск.СоздатьПапку(ЦелевойПуть);
		Исключение
			ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			ТекстОшибки = СтрШаблон("Ошибка при создании папки %1: %2%3",
			                        ЦелевойПуть,
			                        Символы.ПС,
			                        ТекстОшибки);
			ВызватьИсключение ТекстОшибки;
		КонецПопытки;
	КонецЕсли;
	
	Возврат ТекущийПуть;

КонецФункции // СоздатьПапкуНаЯДиске()

// Функция отправки файла на Yandex-Диск
//
// Параметры:
//   ЯДиск          - ЯндексДиск    - объект ЯндексДиск для работы с yandex-диском
//   ПутьКФайлу     - Строка        - путь к отправляемому файлу
//   ЦелевойПуть    - ЯндексДиск    - путь на yandex-диске, куда будет загружен файл
//   Перезаписывать - Булево        - перезаписать файл на Яндекс-диске при загрузке
//
Процедура ОтправитьФайлНаЯДиск(ЯДиск, Знач ПутьКФайлу, Знач ЦелевойПуть, Перезаписывать = Ложь) Экспорт
	
	Лог.Информация("Начало отправки файла на yandex-диск ""%1"" -> ""%2""", ПутьКФайлу, ЦелевойПуть);

	СвойстваДиска = ЯДиск.ПолучитьСвойстваДиска();
	Лог.Отладка("Всего доступно %1 байт", СвойстваДиска.total_space);
	Лог.Отладка("Из них занято %1 байт", СвойстваДиска.used_space);
	
	СвободноМеста = СвойстваДиска.total_space - СвойстваДиска.used_space;

	ИсходныйФайл = Новый Файл(ПутьКФайлу);
	ИмяЗагружаемогоФайла = СтрШаблон("%1/%2", ЦелевойПуть, ИсходныйФайл.Имя);
	
	Если СвободноМеста < ИсходныйФайл.Размер() Тогда
		ТекстОшибки = СтрШаблон("Недостаточно места на ЯДиске для копирования файла ""%1"": есть %2, надо %3",
		                        ПутьКФайлу,
		                        СвободноМеста,
		                        ИсходныйФайл.Размер());
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
	
	Попытка
		ЯДиск.ЗагрузитьНаДиск(ИсходныйФайл.ПолноеИмя, ИмяЗагружаемогоФайла, Перезаписывать);
		Лог.Информация("Файл загружен на yandex-диск ""%1"" -> ""%2""", ПутьКФайлу, ЦелевойПуть);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ТекстОшибки = СтрШаблон("Ошибка загрузки файла ""%1"" в %2:%3%4",
		                        ИсходныйФайл.Имя,
		                        ИмяЗагружаемогоФайла,
		                        Символы.ПС,
		                        ТекстОшибки);
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;

	Попытка
		ЯДиск.ПолучитьСвойстваРесурса(ИмяЗагружаемогоФайла);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ТекстОшибки = СтрШаблон("Ошибка при получении свойств файла %1:%2%3",
		                        ИмяЗагружаемогоФайла,
		                        Символы.ПС,
		                        ТекстОшибки);
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;
	
КонецПроцедуры // ОтправитьФайлНаЯДиск()

// Функция получения файла из Yandex-Диска
//
// Параметры:
//   ЯДиск              - ЯндексДиск    - объект для работы с yandex-диском
//   ПутьНаДиске        - Строка        - расположение файла на yandex-диске
//   ЦелевойПуть        - Строка        - путь, куда будет загружен файл
//   УдалитьИсточник    - Булево        - Истина - удалить файл после загрузки
//
// Возвращаемое значение:
//   Число - код возврата команды
//
Функция ПолучитьФайлИзЯДиска(ЯДиск, Знач ПутьНаДиске, Знач ЦелевойПуть, УдалитьИсточник = Ложь) Экспорт
	
	Лог.Информация("Начало получения файла ""%1"" -> ""%2""", ПутьНаДиске, ЦелевойПуть);

	ПутьКСкачанномуФайлу = "";
	
	Попытка
		ПутьКСкачанномуФайлу = ЯДиск.СкачатьФайлСДиска(ЦелевойПуть, ПутьНаДиске, Истина);

		Лог.Информация("Файл получен %1", ПутьКСкачанномуФайлу);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ТекстОшибки = СтрШаблон("Ошибка получения файла ""%1"": %2%3",
		                        ПутьНаДиске,
		                        Символы.ПС,
		                        ТекстОшибки);
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;

	Если УдалитьИсточник Тогда
		ЯДиск.Удалить(ПутьНаДиске, Истина);
		СвойстваДиска = ЯДиск.ПолучитьСвойстваДиска();
		Лог.Информация("Удален файл на Yandex-Диск %1", ПутьНаДиске);
		Лог.Отладка("Всего доступно %1 байт", СвойстваДиска.total_space);
		Лог.Отладка("Из них занято %1 байт", СвойстваДиска.used_space);
	КонецЕсли;
	
	Возврат ПутьКСкачанномуФайлу;

КонецФункции // ПолучитьФайлИзЯДиска()

// Создает папку в сервисе NextCloud
//
// Параметры:
//   Сервис         - ПодключениеNextCloud    - объект для работы с сервисом NextCloud
//   ЦелевойПуть    - Строка                  - путь к создаваемому каталогу
//
Процедура СоздатьПапкуВNextCloud(Сервис, Знач ЦелевойПуть) Экспорт

	Попытка
		Сервис.Файлы().СоздатьКаталог(ЦелевойПуть);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ТекстОшибки = СтрШаблон("Ошибка при создании папки %1: %2%3",
		                        ЦелевойПуть,
		                        Символы.ПС,
		                        ТекстОшибки);
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;
	
КонецПроцедуры // СоздатьПапкуВNextCloud()

// Процедура - отправляет файл в сервис ТучеСдщгв
//
// Параметры:
//   Сервис           - ПодключениеNextCloud    - объект для работы с сервисом NextCloud
//   ПутьКФайлу       - Строка                  - путь к отправляемому файлу
//   ЦелевойПуть      - Строка                  - путь к каталогу в сервисе NextCloud, куда будет загружен файл
//   Перезаписывать   - Булево                  - перезаписать файл в сервисе NextCloud при загрузке
//
Процедура ОтправитьФайлВNextCloud(Сервис, Знач ПутьКФайлу, Знач ЦелевойПуть, Перезаписывать = Ложь) Экспорт
	
	Лог.Информация("Начало отправки файла в сервис NextCloud ""%1"" -> ""%2""", ПутьКФайлу, ЦелевойПуть);

	ИсходныйФайл = Новый Файл(ПутьКФайлу);
	
	Попытка
		Сервис.Файлы().Отправить(ИсходныйФайл.ПолноеИмя, ЦелевойПуть, ИсходныйФайл.Имя, Перезаписывать);
		Лог.Информация("Файл загружен в сервис NextCloud ""%1"" -> ""%2""", ПутьКФайлу, ЦелевойПуть);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ТекстОшибки = СтрШаблон("Ошибка загрузки файла ""%1"" в ""%2/%1"":%3%4",
		                        ИсходныйФайл.Имя,
		                        ЦелевойПуть,
		                        Символы.ПС,
		                        ТекстОшибки);
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;

КонецПроцедуры // ОтправитьФайлВNextCloud()

// Процедура - получает файл из сервиса NextCloud
//
// Параметры:
//   Сервис             - ПодключениеNextCloud    - объект для работы с сервисом NextCloud
//   ПутьНаДиске        - Строка                  - расположение файла на сервисе NextCloud
//   ЦелевойКаталог     - Строка                  - путь к каталогу, куда будет загружен файл
//   УдалитьИсточник    - Булево                  - Истина - удалить файл после загрузки
//
// Возвращаемое значение:
//   Строка    - путь к полученному файлу
//
Функция ПолучитьФайлИзNextCloud(Сервис, Знач ПутьНаДиске, Знач ЦелевойКаталог, УдалитьИсточник = Ложь) Экспорт
	
	ЧастиПути = ЧастиПути(ПутьНаДиске);

	ЦелевойПуть = ОбъединитьПути(ЦелевойКаталог, ЧастиПути.Имя);

	Лог.Информация("Начало получения файла ""%1"" -> ""%2""", ПутьНаДиске, ЦелевойПуть);

	Попытка
		Сервис.Файлы().Получить(ПутьНаДиске, ЦелевойПуть, Истина);

		Лог.Информация("Файл получен ""%1""", ЦелевойПуть);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ТекстОшибки = СтрШаблон("Ошибка получения файла ""%1"": %2%3",
		                        ПутьНаДиске,
		                        Символы.ПС,
		                        ТекстОшибки);
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;

	Если УдалитьИсточник Тогда
		Сервис.Файлы.Удалить(ПутьНаДиске);
		Лог.Информация("Удален файл в сервисе NextCloud ""%1""", ПутьНаДиске);
	КонецЕсли;
	
	Возврат ЦелевойПуть;

КонецФункции // ПолучитьФайлИзNextCloud()

// Процедура подключает указанный сетевой диск
//
// Параметры:
//   ИмяУстройства         - Строка    - имя (буква) подключаемого диска
//   ИмяРесурса            - Строка    - сетевой путь к подключаемому ресурсу
//   Пользователь          - Строка    - пользователь от имени которого выполняется подключение
//   ПарольПользователя    - Строка    - пароль пользователя от имени которого выполняется подключение
//
Процедура ПодключитьДиск(ИмяУстройства, ИмяРесурса, Пользователь, ПарольПользователя) Экспорт

	Лог.Информация("Начало подключения сетевого ресурса ""%1"" к устройству ""%2""",
	               ИмяРесурса,
	               ИмяУстройства);

	КомандаРК = Новый Команда;
	
	КомандаРК.УстановитьКоманду("net");
	КомандаРК.ДобавитьПараметр("use");
	КомандаРК.ДобавитьПараметр(ИмяУстройства);
	КомандаРК.ДобавитьПараметр(ИмяРесурса);
	КомандаРК.ДобавитьПараметр(ПарольПользователя);
	КомандаРК.ДобавитьПараметр("/USER:" + Пользователь);

	КомандаРК.УстановитьИсполнениеЧерезКомандыСистемы( Ложь );
	КомандаРК.ПоказыватьВыводНемедленно( Ложь );
	
	КодВозврата = КомандаРК.Исполнить();

	ОписаниеРезультата = КомандаРК.ПолучитьВывод();
	
	Если КодВозврата = 0 Тогда
		Лог.Информация("Подключен сетевой ресурс ""%1"" к устройству ""%2"": %3",
		               ИмяРесурса,
		               ИмяУстройства,
		               ОписаниеРезультата);
	Иначе
		ВызватьИсключение СтрШаблон("Ошибка ошибка подключения ресурса ""%1"" к устройству ""%2"", код ошибки %3: %4%5",
		                            ИмяРесурса,
		                            ИмяУстройства,
		                            КодВозврата,
		                            Символы.ПС,
		                            ОписаниеРезультата);
	КонецЕсли;
	
КонецПроцедуры // ПодключитьДиск()

// Процедура отключает указанный сетевой диск
//   
// Параметры:
//   ИмяУстройства    - Строка    - имя (буква) отключаемого диска
//
Процедура ОтключитьДиск(ИмяУстройства) Экспорт

	Лог.Информация("Начало отключения устройства ""%1""", ИмяУстройства);

	КомандаРК = Новый Команда;
	
	КомандаРК.УстановитьКоманду("net");
	КомандаРК.ДобавитьПараметр("use");
	КомандаРК.ДобавитьПараметр(ИмяУстройства);
	КомандаРК.ДобавитьПараметр("/DELETE");

	КомандаРК.УстановитьИсполнениеЧерезКомандыСистемы( Ложь );
	КомандаРК.ПоказыватьВыводНемедленно( Ложь );
	
	КодВозврата = КомандаРК.Исполнить();

	ОписаниеРезультата = КомандаРК.ПолучитьВывод();
	
	Если КодВозврата = 0 Тогда
		Лог.Информация("Отключено устройство ""%1"": %2",
		               ИмяУстройства,
		               ОписаниеРезультата);
	Иначе
		ВызватьИсключение СтрШаблон("Ошибка ошибка отключения устройства ""%1"", код ошибки %2: %3%4",
		                            ИмяУстройства,
		                            КодВозврата,
		                            Символы.ПС,
		                            ОписаниеРезультата);
	КонецЕсли;
	
КонецПроцедуры // ОтключитьДиск()

// Процедура приводит переданный путь к "нормализованному" виду
//   
// Параметры:
//   Путь    - Строка    - (возвр.) нормализуемый путь
//
Процедура НормализоватьПуть(Путь) Экспорт

	Попытка
		Файл = Новый Файл(Путь);
	Исключение
		ТекстОшибки = СтрШаблон("Ошибка нормализации пути ""%1"":%2%3", Путь, Символы.ПС, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;

	Лог.Отладка("Нормализован путь ""%1"" -> ""%2""", Путь, Файл.ПолноеИмя);

	Путь = Файл.ПолноеИмя;

КонецПроцедуры // НормализоватьПуть()

#КонецОбласти // ПрограммныйИнтерфейс

#Область СлужебныеПроцедурыИФункции

// Функция - ищет и возвращает путь к архиватору 7-zip с использованием команды where/whereis
//
// Возвращаемое значение:
//  Строка   - путь к исполняемому файлу архиватора 7-zip
//
Функция НайтиАрхиваторКомандойПоиска()

	ЭтоWindows = ПараметрыСистемы.ЭтоWindows();
	НайденныйПуть = Неопределено;

	Команда = Новый Команда();

	Если ЭтоWindows Тогда
		Команда.УстановитьКоманду("where");
	Иначе
		Команда.УстановитьКоманду("whereis");
	КонецЕсли;
	Команда.ДобавитьПараметр("7z");

	КодВозврата = Команда.Исполнить();
	ВыводКоманды = Команда.ПолучитьВывод();

	Если КодВозврата = 0 Тогда
		НайденныйПуть = ВыводКоманды;
		Если НЕ ЭтоWindows Тогда
			НайденныйПуть = СтрЗаменить(НайденныйПуть, "7z:", ""); 
			ЧастиСтроки = СтрРазделить(СокрЛП(НайденныйПуть), " ");
			НайденныйПуть = ЧастиСтроки[0];

			Если ПустаяСтрока(НайденныйПуть) Тогда
				НайденныйПуть = Неопределено;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;

	Возврат НайденныйПуть;

КонецФункции // НайтиАрхиваторКомандойПоиска()

// Функция - ищет и возвращает путь к архиватору 7-zip в стандартных каталогах установки программ
//
// Возвращаемое значение:
//  Строка   - путь к исполняемому файлу архиватора 7-zip
//
Функция НайтиАрхиваторВКаталогахПрограмм()

	КаталогиПрограмм = Новый Массив();

	Если ПараметрыСистемы.ЭтоWindows() Тогда
		КаталогиПрограмм.Добавить(ПолучитьПеременнуюСреды("ProgramFiles"));
		КаталогиПрограмм.Добавить(ПолучитьПеременнуюСреды("ProgramFiles(x86)"));
		ИмяИсполняемогоФайла = "7z.exe";
	Иначе
		КаталогиПрограмм.Добавить("/usr/bin");
		КаталогиПрограмм.Добавить("/usr/local/bin");
		ИмяИсполняемогоФайла = "7z";
	КонецЕсли;

	НайденныйПуть = Неопределено;

	Для Каждого ТекКаталог Из КаталогиПрограмм Цикл
		Массив7ZIP = НайтиФайлы(ТекКаталог, ИмяИсполняемогоФайла, True);
		Если ЗначениеЗаполнено(Массив7ZIP) Тогда
			НайденныйПуть = Массив7ZIP[0].ПолноеИмя;
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Возврат НайденныйПуть;

КонецФункции // НайтиАрхиваторВКаталогахПрограмм()

// Функция - ищет и возвращает путь к архиватору 7-zip
//
// Возвращаемое значение:
//  Строка   - путь к исполняемому файлу архиватора 7-zip
//
Функция НайтиАрхиватор()

	НайденныйПуть = НайтиАрхиваторКомандойПоиска();

	Если НЕ ЗначениеЗаполнено(НайденныйПуть) Тогда
		НайденныйПуть = НайтиАрхиваторВКаталогахПрограмм();
	КонецЕсли;

	Возврат НайденныйПуть;

КонецФункции // НайтиАрхиватор()

// Функция создает файл-список файлов архива и возвращает количество
//   
// Параметры:
//   ПутьКАрхиву         - Строка    - путь к файлу архива
//   ИмяСпискаФайлов     - Строка    - имя файла-списка файлов архива
//
// Возвращаемое значение:
//   Число - количество файлов архива
//
Функция СоздатьСписокФайлов(ПутьКАрхиву, ИмяСпискаФайлов)

	ВремАрхив = Новый Файл(ПутьКАрхиву);

	МассивФайловЧастей = НайтиФайлы(ВремАрхив.Путь, ВремАрхив.Имя + ".???", Ложь);
	Лог.Отладка("Всего частей: " + МассивФайловЧастей.Количество());

	ЗаписьСписка = Новый ЗаписьТекста(ИмяСпискаФайлов, КодировкаТекста.UTF8, , Ложь);

	РасчетХешей = Новый ХешированиеДанных(ХешФункция.MD5);

	Для каждого ФайлЧасти Из МассивФайловЧастей Цикл
		РасчетХешей.ДобавитьФайл(ФайлЧасти.ПолноеИмя);
		ЗаписьСписка.ЗаписатьСтроку(СтрШаблон("%1 %2", ФайлЧасти.Имя, РасчетХешей.ХешСуммаСтрокой));
		РасчетХешей.Очистить();
	КонецЦикла;
	ЗаписьСписка.Закрыть();

	Возврат МассивФайловЧастей.Количество();

КонецФункции // СоздатьСписокФайлов()

// Функция - разбивает переданный путь к файлу на части
//
// Параметры:
//   ПутьКФайлу    - Строка    - путь к файлу/каталогу
//
// Возвращаемое значение:
//   Структура    - части пути к файлу
//     *Имя           - Строка    - имя файла/каталога
//     *Путь          - Строка    - путь к каталогу в котором расположен файл/каталог
//     *ПолныйПуть    - Строка    - полный путь к файлу/каталогу
//
Функция ЧастиПути(Знач ПутьКФайлу)

	Результат = Новый Структура();
	
	ПутьКФайлу = СтрЗаменить(ПутьКФайлу, "\", "/");

	Результат.Вставить("ПолныйПуть", ПутьКФайлу);

	ЧастиПути = СтрРазделить(ПутьКФайлу, "/", Ложь);
	
	Результат.Вставить("Имя", ЧастиПути[ЧастиПути.ВГраница()]);

	ЧастиПути.Удалить(ЧастиПути.ВГраница());

	Результат.Вставить("Путь", СтрСоединить(ЧастиПути, "/"));

	Возврат Результат;

КонецФункции // ЧастиПути()

#КонецОбласти // СлужебныеПроцедурыИФункции

Лог = ПараметрыСистемы.Лог();
