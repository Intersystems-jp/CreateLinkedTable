# CreateLinkedTable  
![image](https://user-images.githubusercontent.com/24215130/187606574-625d9e98-9632-40f6-8c12-a571d3416a51.png)
**このサンプルはInterSystemsで正式サポートしているものではありません。ご自身の責任においてご利用ください。  
　　また、サンプル公開時の最新IRISバージョンで作成しておりますので、実際に使用されるIRISバージョン毎に動作確認をお願いします。** 
***
SQLゲートウェイ接続した外部データソースへのリンクテーブルをプログラムで行う方法

以下の「(管理ポータルで行う)リンクテーブルをプログラムで行う方法」で使用するサンプルです。
[https://faq.intersystems.co.jp/csp/knowledge/result.csp?DocNo=543](https://faq.intersystems.co.jp/csp/faq/result.csp?DocNo=543)


## １．サンプルについて
リンクテーブルの作成には、%SYSTEM.SQL.Schema クラスの [CreateLinkedTable メソッド](https://docs.intersystems.com/irislatest/csp/documatic/%25CSP.Documatic.cls?&LIBRARY=%25SYS&CLASSNAME=%25SYSTEM.SQL.Schema#CreateLinkedTable)を使用します。

このクラスメソッドを使用して実行する場合、リンクテーブルはReadOnly属性で作成されます。
ReadOnly属性を外したい場合は、第7引数の columnMap で指定する必要があります。

このサンプルでは、全てのフィールド(カラム)に対して ReadOnlyなし(0) を設定する columnMap を作成し、リンクテーブルを作成しています。
また、primaryKey はリンク元テーブルの primaryKey を引き継げるようにしています。
  
  
## ２．サンプルの使用手順
- サンプルのインポート
実行したいネームスペースに ISC.LinkUtils クラスをインポートします。

スタジオをご利用の場合は、ISC.LinkUtils.xml ファイルをドラッグ＆ドロップするとインポートできます。

管理ポータルでインポートされる場合は、[システムエクスプローラ] > [クラス] > (ネームスペース選択) > インポートボタンクリック でファイルを選択し、インポートを行います。

VSCodeをご利用の場合は、使用したい IRIS に接続し、ISC.LinkUtils クラスを保存（Ctrl＋S）するとインポートされます。


- 実行方法

実行例は以下の通りです。
```
do ##class(ISC.LinkUtils).LinkTable("<dsn>","<Schema>","<Table>","<localClass>")
/// 第1引数：dsn - SQLゲートウェイ接続名
/// 第2引数：Schema - リンク元のスキーマ名　
/// 第3引数：Table - リンク元のテーブル名　
/// 第4引数：localClass - リンク先のクラス名　例：User.LinkedClass　
```
