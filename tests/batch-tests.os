﻿#Использовать fs
#Использовать "../src/core"
#Использовать "../src/cmd"

Перем Лог;                       //    - логгер

// Процедура выполняется после запуска теста
//
Процедура ПередЗапускомТеста() Экспорт
	
	Лог = ПараметрыСистемы.Лог();

КонецПроцедуры // ПередЗапускомТеста()

// Процедура выполняется после запуска теста
//
Процедура ПослеЗапускаТеста() Экспорт

КонецПроцедуры // ПослеЗапускаТеста()

&Тест
Процедура ТестДолжен_ВыполнитьПакетныйЗапускКоманд() Экспорт

	Лог.Информация("Тест: Пакетный запуск команды");

	ИмяСервера = ПолучитьПеременнуюСреды("CPDB_SQL_SRVR");
	ИмяПользователя = ПолучитьПеременнуюСреды("CPDB_SQL_USER");
	ПарольПользователя = ПолучитьПеременнуюСреды("CPDB_SQL_PWD");

	ПодключениеКСУБД = Новый ПодключениеMSSQL(ИмяСервера, ИмяПользователя, ПарольПользователя);
	
	РаботаССУБД = Новый РаботаССУБД(ПодключениеКСУБД);

	ИмяБазы = "cpdb_test_db_batch";

	Если РаботаССУБД.БазаСуществует(ИмяБазы) Тогда
		РаботаССУБД.УдалитьБазуДанных(ИмяБазы);
	КонецЕсли;

	ФайлПакетногоЗапуска = "./tests/fixtures/batch_test_sql.json";

	Контекст = Новый Структура();

	Аргументы = Новый Массив();
	Аргументы.Добавить("batch");
	Аргументы.Добавить(ФайлПакетногоЗапуска);

	Контекст.Вставить("АргументыКоманднойСтроки", Новый ФиксированныйМассив(Аргументы));

	КаталогИсходников = ОбъединитьПути(ТекущийСценарий().Каталог, "..", "src");

	ЗагрузитьСценарий(ОбъединитьПути(КаталогИсходников, "cmd", "cpdb.os"), Контекст);

КонецПроцедуры // ТестДолжен_ВыполнитьПакетныйЗапускКоманд()

&Тест
Процедура ТестДолжен_ВыполнитьЗапускКомандыИспользуяПараметрыИзФайла() Экспорт

	Лог.Информация("Тест: Пакетный запуск команды с параметрами из файла");

	ИмяСервера = ПолучитьПеременнуюСреды("CPDB_SQL_SRVR");
	ИмяПользователя = ПолучитьПеременнуюСреды("CPDB_SQL_USER");
	ПарольПользователя = ПолучитьПеременнуюСреды("CPDB_SQL_PWD");

	ПодключениеКСУБД = Новый ПодключениеMSSQL(ИмяСервера, ИмяПользователя, ПарольПользователя);
	
	РаботаССУБД = Новый РаботаССУБД(ПодключениеКСУБД);

	ИмяБазы = "cpdb_test_db_params";

	Если РаботаССУБД.БазаСуществует(ИмяБазы) Тогда
		РаботаССУБД.УдалитьБазуДанных(ИмяБазы);
	КонецЕсли;

	ФайлПараметров = "./tests/fixtures/params_test_sql.json";

	Контекст = Новый Структура();

	Аргументы = Новый Массив();
	Аргументы.Добавить("database");
	Аргументы.Добавить("create");
	Аргументы.Добавить("--params");
	Аргументы.Добавить(ФайлПараметров);

	Контекст.Вставить("АргументыКоманднойСтроки", Новый ФиксированныйМассив(Аргументы));
	Контекст.Вставить("ЭтоТест"                 , Истина);

	КаталогИсходников = ОбъединитьПути(ТекущийСценарий().Каталог, "..", "src");

	ЗагрузитьСценарий(ОбъединитьПути(КаталогИсходников, "cmd", "cpdb.os"), Контекст);

	ТекстОшибки = СтрШаблон("Ошибка создания базы данных ""%1""", ИмяБазы);

	Утверждения.ПроверитьИстину(РаботаССУБД.БазаСуществует(ИмяБазы), ТекстОшибки);

	РаботаССУБД.УдалитьБазуДанных(ИмяБазы);

КонецПроцедуры // ТестДолжен_ВыполнитьПакетныйЗапускКоманд()
