Class ISC.LinkUtils Extends %RegisteredObject
{

/// メソッド：SQL Gateway DSN 定義の有無確認
/// 引数  　：1 - SQLゲートウェイ接続名
/// 戻り値　：0　　　定義なし
///       　  1以上　定義あり
/// 実行例　：write ##class(ISC.LinkUtils).gatewayExists("CHOFU-SEIZO")
ClassMethod gatewayExists(gateway As %String) As %Boolean
{
	
	&sql(select ID into :exist from %Library.sys_SQLConnection where Connection_Name=:gateway)
	if (SQLCODE '= 0) {
		set exist = 0
	}
	quit exist
}

/// メソッド：リンクテーブル作成
/// 引数    　gateway   SQL Gateway DSN名
///         　schema    スキーマ名
///         　table     テーブル名
///         　newSchema 新スキーマ名(なしの場合はスキーマ名と同じ)
///         　prikey    プライマリーキー(なしの場合はソーステーブルと同じ)
/// 実行例　：do ##class(ISC.LinkUtils).LinkTable("CHOFU-SEIZO","f","アフター基本ファイル")
///         　do ##class(ISC.LinkUtils).LinkTable("CHOFU-SEIZO","f","アフター明細ファイル")
ClassMethod LinkTable(gateway As %String, schema As %String, table As %String, newSchema As %String = "", prikey As %String = "") As %Status
{
	
	// カラム情報の取得
	set rs= ##class(%Library.ResultSet).%New("%GTWCatalog:SQLFields")
	set sc = rs.Execute(gateway, table, schema)
	if ($$$ISERR(sc)) {
		do $system.OBJ.DisplayError(sc)
		quit sc
	}
	set tname = schema _ "." _ table
	while rs.Next() {
		// columnMap("リンク・テーブルからの列名") = $lb("新規プロパティ名","新しい SQL フィールド名","read-only(1/0)")
		// 今回は列名はリンク元と同じ、ReadOnlyなし(0) で設定 
		set cols(rs."COLUMN_NAME") = $lb(rs."COLUMN_NAME",rs."COLUMN_NAME",0)
	}
	do rs.Close()
	if '$data(cols) {
		set sc = $system.Status.Error(5001, "No meta-data found for " _ tname)
		do $system.OBJ.DisplayError(sc)
		quit sc
	}
	
	// PrimaryKeyの設定（引数で渡さずに自動設定にしたい場合）
	if (prikey '= "") {
		set pkeys = prikey
	} else {

		set rs= ##CLASS(%Library.ResultSet).%New("%GTWCatalog:SQLPrimaryKeys")

		set sc = rs.Execute(gateway, tname)
		if ($$$ISERR(sc)) {
			do $system.OBJ.DisplayError(sc)
			quit sc
		}
		set pkeys = ""
		while rs.Next() {
			if pkeys '= "" {
				set pkeys = pkeys _ ","
			}
			set pkeys = pkeys _ rs."COLUMN_NAME"
		}
		do rs.Close()
	}
	
	// スキーマ・テーブル名の設定
	if (newSchema = "") {
		set ctName = schema _ "." _ table
	} else {
		set ctName = newSchema _ "." _ table
	}
	
	// リンクテーブル作成
	set sc=##class(%SYSTEM.SQL.Schema).CreateLinkedTable(gateway,schema,table,pkeys,ctName,table,.cols)
	
	if ($$$ISERR(sc)) {
		do $system.OBJ.DisplayError(sc)
		quit sc
	}
	quit $$$OK
}

/// メソッド：テーブル削除
/// 実行例　：do ##class(ISC.LinkUtils).DeleteTable("f.アフター明細ファイル")
///       　  do ##class(ISC.LinkUtils).DeleteTable("f.アフター基本ファイル")
ClassMethod DeleteTable(tname As %String) As %Status
{
	set sc=$SYSTEM.OBJ.Delete(tname)
	quit sc
}

Storage Default
{
<Data name="LinkUtilsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
</Data>
<DataLocation>^ISC.LinkUtilsD</DataLocation>
<DefaultData>LinkUtilsDefaultData</DefaultData>
<IdLocation>^ISC.LinkUtilsD</IdLocation>
<IndexLocation>^ISC.LinkUtilsI</IndexLocation>
<StreamLocation>^ISC.LinkUtilsS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
