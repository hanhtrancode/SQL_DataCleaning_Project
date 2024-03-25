
--Viết một stored procedure sử dụng cursor để tính tổng số lượng sản phẩm có sẵn trong từng cửa hàng (store) từ bảng sales.stores và bảng production.stocks. 
--Hiển thị tên cửa hàng và tổng số lượng sản phẩm.

--data capture
select s.store_id, s2.quantity as quantity from sales.stores s
inner join production.stocks s2
on s.store_id=s2.store_id

--declare 3 variables
declare @quantity_store_one int 
declare @quantity_store_two int 
declare @quantity_store_three int 

declare @store_id int
declare @quantity int

set @quantity_store_one  =0
set @quantity_store_two  =0
set @quantity_store_three  =0

declare cursorStore cursor static for 
	select s.store_id, s2.quantity as quantity from sales.stores s
	inner join production.stocks s2
	on s.store_id=s2.store_id

open cursorStore

fetch next from cursorStore into @store_id, @quantity
while @@FETCH_STATUS=0 
begin
	if @store_id=1
	begin
		set	@quantity_store_one = @quantity_store_one + @quantity
		fetch next from cursorStore into @store_id, @quantity

	end
	else
		if @store_id=2
		begin
			set	@quantity_store_two = @quantity_store_two + @quantity
			fetch next from cursorStore into @store_id, @quantity

		end
		else 
			set	@quantity_store_three = @quantity_store_three + @quantity
			fetch next from cursorStore into @store_id, @quantity
end
select @quantity_store_one

--method 2
CREATE TABLE #Result (
	store_id int,
	quantity int
)

SELECT s.store_id, s2.quantity as quantity  FROM sales.stores s 
INNER JOIN production.stocks s2
ON s.store_id  = s2.store_id

DROP TABLE #Result

SELECT * FROM #Result


DECLARE @store_id int
DECLARE @quantity int
DECLARE @number int

DECLARE @result_store_id int
DECLARE @result_quantity int
DECLARE @dem int

SET @result_store_id = 0
SET @result_quantity = 0
SET @dem = 1


DECLARE cursorStore4 CURSOR scroll FOR
	SELECT
		ROW_NUMBER() OVER(ORDER BY s.store_id) AS [ROW_NUMBER],
		s.store_id, 
		s2.quantity  as quantity 
	FROM sales.stores s 
	INNER JOIN production.stocks s2
	ON s.store_id  = s2.store_id
	WHERE s.store_id = 1
	ORDER BY [ROW_NUMBER] asc

OPEN cursorStore4

FETCH ABSOLUTE @dem FROM cursorStore4 INTO @number, @store_id, @quantity

WHILE @@FETCH_STATUS = 0
BEGIN
	--illustrate xem cái cursor nó chạy đến đâu
	PRINT 'Store id: ' + CAST(@store_id as varchar(50))
	PRINT 'Quantity: ' + CAST(@quantity as varchar(50))
	--giá trị này  sẽ bằng với giá trị ban đầu của nó
	SELECT @result_store_id = store_id, @result_quantity = quantity FROM #Result WHERE store_id = @store_id
	SET @result_store_id = (SELECT store_id FROM #Result WHERE store_id = @store_id)
	SET @result_quantity = (SELECT quantity FROM #Result WHERE store_id = @store_id)
	PRINT 'Gia tri store id luc sau ' + CAST(@result_store_id as varchar(50))
	PRINT 'Gia tri quantity id luc sau ' + CAST(@result_quantity as varchar(50))
	DECLARE @update int = @result_quantity + @quantity
	IF @result_store_id > 0
	BEGIN
		PRINT 'Go to here 1'
		UPDATE #Result SET quantity = @update WHERE store_id = @result_store_id
		SET @dem = @dem + 1
		PRINT 'AAAAA: ' + CAST(@dem as varchar(50))
		FETCH ABSOLUTE @dem  FROM cursorStore4 INTO @number, @store_id, @quantity
	END
	ELSE
	BEGIN
		PRINT 'Go to here 2'
		INSERT INTO #Result VALUES (@store_id, @quantity)
		SET @dem = @dem + 1
		PRINT 'BBBBBB: ' + CAST(@dem as varchar(50))
		FETCH ABSOLUTE @dem FROM cursorStore4 INTO @number, @store_id, @quantity
	END
	PRINT 'Dem ' + CAST(@dem as varchar(50))
END

CLOSE cursorStore4
DEALLOCATE cursorStore4
--Viết một stored procedure sử dụng cursor để cập nhật trường list_price trong bảng production.products dựa trên mức giảm giá (discount) từ bảng sales.order_items. 
--Sản phẩm có giá trị giảm giá cao hơn 20% sẽ được cập nhật giá bán (list_price) giảm 10%.

CREATE TABLE #Result (
	store_id int,
	quantity int
)

SELECT s.store_id, s2.quantity as quantity  FROM sales.stores s 
INNER JOIN production.stocks s2
ON s.store_id  = s2.store_id

DROP TABLE #Result

SELECT * FROM #Result


DECLARE @store_id int
DECLARE @quantity int

DECLARE @result_store_id int
DECLARE @result_quantity int
DECLARE @count int = 0

SET @result_store_id = 0
SET @result_quantity = 0

DECLARE cursorStore5 CURSOR STATIC FOR
	SELECT s.store_id, s2.quantity  as quantity FROM sales.stores s 
	INNER JOIN production.stocks s2
	ON s.store_id  = s2.store_id
	WHERE s.store_id = 1

OPEN cursorStore5

FETCH NEXT FROM cursorStore5 INTO @store_id, @quantity

WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT 'Store id: ' + CAST(@store_id as varchar(50))
	PRINT 'Quantity: ' + CAST(@quantity as varchar(50))
	SET @result_store_id = (SELECT store_id FROM Result WHERE store_id = @store_id)
	SET @result_quantity = (SELECT quantity FROM Result WHERE store_id = @store_id)
	PRINT 'Gia tri store id luc sau ' + CAST(@result_store_id as varchar(50))
	PRINT 'Gia tri quantity id luc sau ' + CAST(@result_quantity as varchar(50))
	DECLARE @update int = @result_quantity + @quantity
	PRINT 'Dem: ' + CAST(@count as varchar(50))
	IF @result_store_id = 0
	BEGIN
		INSERT INTO Result VALUES (@store_id, @quantity)
		SET @count = @count + 1
		FETCH NEXT FROM cursorStore5 INTO @store_id, @quantity	
	END
	ELSE
	BEGIN
		UPDATE Result SET quantity = @update WHERE store_id = @result_store_id
		SET @count = @count + 1
		FETCH NEXT FROM cursorStore5 INTO @store_id, @quantity
	END
END

CLOSE cursorStore5
DEALLOCATE cursorStore5

--- Viết một transaction để thực hiện việc chuyển đổi tất cả các đơn hàng có trạng thái "Pending" 
--thành trạng thái "Completed" và cập nhật ngày hoàn thành là ngày hiện tại. 

create table #temp1(
	order_id int, 
	order_status int)
insert into #temp1
	select order_id, order_status from sales.orders

declare @order_id int

set @order_id = 1


begin transaction
	while @order_id <= (select max(order_id) from #temp1)
	begin
		if (select order_status from #temp1 where order_id=@order_id) <> 4
		begin
			update #temp1
			set order_status=4
			where order_id=@order_id
		end
		set @order_id=@order_id+1
	end
	commit
	
	

	-- Hãy tạo một transaction để tính tổng số tiền của tất cả các đơn hàng đã hoàn thành và cập nhật vào bảng thông tin khách hàng. 

create

select * from sales. order_items
declare @order_id int 
declare @revenue decimal(10,2)
declare @total_revenue decimal (10,2)
set @total_revenue=0
begin transaction
	while @order_id <= (select max(order_id) from sales.order_items)
	if (select order_status from 
	begin 
		set @revenue

--- Viết một transaction để xóa tất cả các đơn hàng đã bị từ chối(order_status=3) và cập nhật lại số lượng hàng tồn kho cho mỗi sản phẩm liên quan.
create table #temp2 ( order_id int, order_status int, Tong_so_luong int)
insert into #temp2
select o.order_id, o.order_status,sum (oi.quantity) as [Tong_so_luong]
from sales.order_items oi
join sales.orders o
on oi.order_id=o.order_id
group by  o.order_id, o.order_status
order by order_id

create table #temp3(order_id int, Tong_ton_kho int)
insert into #temp3
select o.order_id, sum(quantity) as [Tong_ton_kho] from production.stocks p
join sales.orders o
on o.store_id= p.store_id
group by o.order_id
order by o.order_id 

declare @order_id int 
declare @Tong_so_luong 
declare @Tong_ton_kho

begin transaction