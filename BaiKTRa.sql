create database University

create schema common
create schema human 
create schema data

drop table if exists common.DMKHOA
create table common.DMKHOA(
	MaKhoa VARCHAR(20) primary key,
	TenKhoa VARCHAR(30)
);
create table common.DMNGANH(
	MaNganh varchar(20) primary key,
	TenNganh VARCHAR (20),
	MaKhoa varchar(20)
	foreign key (MaKhoa) references common.DMKHOA(MaKhoa)
);

create table common.DMLOP(
	MaLop varchar(20) primary key,
	TenLop Varchar(20),
	MaNganh varchar (20),
	KhoaHoc Varchar(20),
	HeDT Varchar(20),
	NamNhapHoc varchar(20),
	foreign key (MaNganh) references common.DMNGANH(MaNganh)
);

create table data.DMHOCPHAN(
	MaHP int primary key identity(1,1),
	TenHp Varchar(20),
	
	Sodvht int,
	MaNganh int,
	HocKy int
);
drop table if exists data.DiemHP
create table data.DIEMHP(
	MaSV int ,
	MaHP int ,
	DiemHp float,
	foreign key(MaSV) references human.SINHVIEN(MaSV),
	foreign key(MaHp) references data.DMHOCPHAN (MaHP)
);
create table human.SINHVIEN(
	 MaSV int primary key identity(1,1),
	 HoTen VARCHAR (20),
	 
	 
	 MaLop varchar(20),
	 Gioitinh int ,
	 Ngaysinh varchar(20),
	 DiaChi varchar(20)
	 foreign key (MaLop) references common.DMLOP(MaLop)
);

insert into common.DMKHOA values
	('CNTT', 'Công nghệ thông tin'),
	('KT', 'Kế Toán'),
	('SP', 'Sư phạm')
go

insert into common.DMNGANH values
	('140902', 'Sư phạm toán tin', 'SP'),
	('480202', 'Tin học ứng dụng', 'CNTT')
go

insert into common.DMLOP values
	('CT11', 'Cao đẳng tin học', '480202', '11', 'TC', '2013'),
	('CT12', 'Cao đẳng tin học', '480202', '12', 'CĐ', '2013'),
	('CT13', 'Cao đẳng tin học', '480202', '13', 'CĐ', '214')
go

insert into human.SINHVIEN values
	('Phan Thanh', 'CT12', 0, '19900912', 'Tuy Phuwowcs'),
	('Nguyễn Thị Cẩm', 'CT12', 1, '19940112', 'Quy Nhơn'),
	('Võ Thị Hà', 'CT12', 1, '19950702', 'An Nhơn'),
	('Trần Hoài Nam', 'CT12', 0, '19940405', 'Tây sơn'),
	('Trần Văn Hoàng', 'CT13', 0, '19950804', 'Vĩnh Thạnh'),
	('Đặng Thị Thảo', 'CT13', 1, '19950612', 'Quy Nhơn'),
	('Lê Thị Sen', 'CT13', 1, '19940812', 'Phú Cát'),
	('Nguyễn Văn Huy', 'CT11', 0, '19950604', 'Phú Mỹ'),
	('Trần Thị Hoa', 'CT11', 1, '19940809', 'Hoài Nhơn')
go

insert into data.DMHOCPHAN values
	('Toán cao cấp A1', 4, 480202, 1),
	('Tiếng Anh 1', 3, 480202, 1),
	('Vật lý đại cương', 4, 480202, 1),
	('Tiến anh 2', 7, 480202, 1),
	('Tiếng anh 1', 3, 140902, 2),
	('Xác suất thống kê', 3, 140902, 2)
go

insert into data.DIEMHP values
	(2, 2, 5.9),
	(2, 3, 4.5),
	(3, 1, 4.3),
	(3, 2, 6.7),
	(3, 3, 7.3),
	(4, 1, 4.0),
	(4, 2, 5.2),
	(4, 3, 3.5),
	(5, 1, 9.8),
	(5, 2, 7.9),
	(5, 3, 7.5),
	(6, 1, 6.1),
	(6, 2, 5.6),
	(6, 3, 4.0),
	(7, 1, 6.2)
go

--Them truong DiemHe4

alter table  data.DIEMHP
add  DiemHe4 int

alter table data.DIEMHP
drop column DiemHe4

--Thực hiện viết câu lệnh xoá dữ liệu bảng DiemHP với điều kiện MaSV là 007.
delete data.DIEMHP
where MaSV=007

--Xoá khỏi bảng DMLOP những lớp không có sinh viên nào


--Cập nhật dữ liệu của sinh viên 006 với mã học phần là 003 lên số điểm là 10
update data.DIEMHP
set DiemHp=10
where MaSV=006 and MaHp=003

--4. Thêm cột XepLoai, cập nhật dữ liệu cột XepLoai theo yêu cầu sau:
    -- Nếu DiemTBC ≥ 8 thì xếp loại Giỏi, ngược lại
    -- Nếu DiemTBC ≥7 thì xếp loại Khá, ngược lại
    -- Nếu DiemTBC ≥5 thì xếp loại TrungBinh, ngược lại là Yếu
drop table if exists #DiemTB
create table #DiemTB(
MaSV int , DiemTBC float)
insert into  #DiemTB
select MaSv, sum(DiemHp)/ count( MaSV)  
from data.DIEMHP
group by MaSv

select * from #DiemTB


select *, 
	case when DiemTBC>=8 then 'Gioi'
		when DiemTBC >=7 then 'Kha'
		when DiemTBC >=5 then 'Trung Binh'
		else 'Yeu'
	end as [XepLoai]
from #DiemTb

--Hiển thị danh sách gồm: MaSV, HoTen, MaLop, NgaySinh, GioiTinh, NamSinh của những sinh viên có họ không bắt đầu bằng chữ N, L, T
select * from human.Sinhvien
select * 
from human.SINHVIEN
where left(HoTen,1) not in ('N','L','T')

--Hiển thị danh sách gồm: MaSV, HoTen, MaLop, NgaySinh, GioiTinh, Tuoi của những sinh viên từ 19-21

With CTE as(
select 
	 *, 2024-year(Ngaysinh) as [SoTuoi]

from human.Sinhvien
)
select * 
from CTE
where [Sotuoi] between 19 and 21
--Mng gia het roi thay a

--11.Hiển thị danh sách MaSV, HoTen, MaLop, DiemHP, MaHP của những sinh viên có điểm  HP từ 5-7 ở học kì 1
select
	sv.MaSV, sv.HoTen, sv.MaLop, hp.DiemHp, hp.MaHp
from human.SINHVIEN sv
join data.DIEMHP hp
on sv.MaSV= hp.MaSV
join data.DMHOCPHAN Hph
on hp.MaHP= Hph.MaHP
where hp.DiemHp between 5 and 7 and Hph.HocKy=1

--12.Hiển thị danh sách MaSV, HoTen, MaLop, MaHP, DiemHP được sắp xếp ưu tiên Mã lớp, Họ tên tăng dần
select
	sv.MaSV, sv.HoTen, sv.MaLop, hp.DiemHp, hp.MaHp
from human.SINHVIEN sv
join data.DIEMHP hp
on sv.MaSV= hp.MaSV
order by sv.MaLop, sv.HoTen

--13. Cho biết điểm trung bình chung của mỗi sinh viên, xuất ra bảng mới có tên DIEMTBC, công thức tính DiemTBC như sau:
with CTE as(
select 
	Hp.MaSv, Hp.MaHP, Hp.DiemHp, Hph.Sodvht, sum(Sodvht) over (partition by MaSv) as [Tong_tin_chi]
from data.DIEMHP Hp
join data.DMHOCPHAN Hph
on Hp.MaHP=Hph.MaHP
),
CTE2 as (
select 
	*,sum( DiemHp*Sodvht)  over (partition by MaSv) as [Tong_diem]
from CTE
),
CTE3 as (
select
	*, [Tong_diem]/[Tong_tin_chi] as [Diem_TBC]
from CTE2
group by MaSv, MaHp, DiemHp, Sodvht, [Tong_diem], [Tong_tin_chi]
	)
select distinct MaSv, Diem_TBC 
into DiemTBC
from CTE3

select * from DiemTBC

--14.Cho biết MaLop, TenLop số lượng nam nữ theo từng lớp

with CTE as(
select distinct l.MaLop, l.TenLop, count(gioitinh) over (partition by l.MaLop) as [So_luong_nam]
from common.DMLop l
join human.SINHVIEN hu
on l.MaLop=hu.MaLop
where Gioitinh=0
),
CTE2 as (
select distinct l.MaLop, l.TenLop, count(gioitinh) over (partition by l.MaLop) as [So_luong_nu]
from common.DMLop l
join human.SINHVIEN hu
on l.MaLop=hu.MaLop
where Gioitinh=1
),
CTE3 as (
select CTE.MaLop, CTE.TenLop, CTE.[So_luong_nam], CTE2.[So_luong_nu]
from CTE
join CTE2
on CTE.MaLop=CTE2.MaLop
)
select * from CTE3

--15.Cho biết MaSV, HoTen, Số các học phần thiếu điểm (DiemHP<5) của mỗi sinh viên
with CTE1 as (
select MaSv,  sum(count(*)) over (partition by MaSv) as [So _hoc_phan_thieu_diem]
from data.DIEMHP
where DiemHp<=5
group by  MaSv, MaHp
),
CTE2 as(
select distinct C.MaSv, hu.HoTen,  C.[So _hoc_phan_thieu_diem]
from CTE1 C
join human.Sinhvien hu
on C.MaSv=hu.MaSV)

select * from CTE2

--16.Tính tổng số đơn vị học có điểm HP < 5 của mỗi sinh viên

select distinct MaSv,  sum(Sodvht) over (partition by MaSv) as [Tong_so_dvh]
from data.DIEMHP d
join data.DMHOCPHAN dm
on d.MaHP=dm.MaHP 
where DiemHp <=5

--17.Cho biết HoTen sinh viên có điểm trung bình cộng các học phần < 3
select * from DiemTBC
where Diem_TBC<3

--18.Cho biết HoTen sinh viên học Tất cả các học phần ở ngành 140902

select hp.MaSv, hp.MaHP, HoTen, MaNganh
from data.DIEMHP hp
join data.DMHOCPHAN hph
on hp.MaHP=hph.MaHP
join human.SINHVIEN hu
on hu.MaSV= hp.MaSV
where MaNganh= 140902

--19.Cho biết MaHP, TenHP có số sinh viên điểm HP < 5 nhiều nhất
with CTE1 as (
select MaSv,  sum(count(*)) over (partition by MaSv) as [So _hoc_phan_thieu_diem]
from data.DIEMHP
where DiemHp<=5
group by  MaSv, MaHp
),
CTE2 as(
select  distinct C.MaSv, hu.HoTen,  C.[So _hoc_phan_thieu_diem]
from CTE1 C
join human.Sinhvien hu
on C.MaSv=hu.MaSV)

select top 1 * from CTE2
order by [So _hoc_phan_thieu_diem] desc

--Cho biết HoTen sinh viên không có học phần HP < 5
with CTE as (
select *,
		case when DiemHp<5 then 1
		else 0
		end as [Cot_dem_diem_<5]
		
from data.DIEMHP
),
CTE2 as (
	select distinct CTE.MaSv,hu.HoTen ,sum([Cot_dem_diem_<5]) over(partition by CTE.MaSv) as [Tong_so_diem_<5]
	from CTE
	join human.SINHVIEN hu
	on hu.MaSV=CTE.MaSv
	
	)
select * from CTE2
where [Tong_so_diem_<5]=0

--Cho biết danh sách các học phần có số đơn vị học trình lớn hơn hoặc bằng số đơn vị học trình của học phần mã 001

select MaHp,  Sodvht
from data.DMHOCPHAN
where sodvht >=4 and MaHp <>1


--Cho biết MaSV, HoTen sinh viên có điểm học phần mã ‘001’ cao nhất

select top 1 MaSv, MaHp, DiemHp
from data.DIEMHP
where MaHp=1 
order by DiemHp desc

--Cho biết sinh viên có điểm học phần nào đó lớn hơn gấp rưỡi điểm trung bình cộng của sinh viên đó
with CTE as(
select Hp.MaSv, Hp.MaHp,  DiemHp/Diem_TBC as [diem_chia]
from data.DIEMHP hp
join DiemTBC Tb
on Tb.MaSV=Hp.MaSV
),
CTE2 as(
select * 
from CTE
where [diem_chia]>1.5
)
select * from CTE2


--Cho biết MaSV đã học ít nhất 1 trong 2 học phần có mã là ‘001’, ‘002’

select MaSV, MaHp
from data.DIEMHP
where MaHp = 1 or MaHp = 2

--Cho biết HoTen sinh viên học ít nhất 3 học phần mã ‘001’, ‘002’, ‘003’

-----Không hiểu yêu cầu của thầy lắm

--27.Cho biết TenLop có sinh viên tên Hoa
select HoTen, hu.MaLop, TenLop
from human.SINHVIEN hu
join common.dmlop l
on l.MaLop = hu.MaLop
where HoTen like '%Hoa'

--28.Liệt kê tên các sinh viên và điểm số của môn học ‘ToanCaoCapA1’ trong học kì 1 sử dụng CTE, có thêm cột Rank, và Row_number
with CTE as (
select MaSv, hu.MaHp, TenHp, DiemHp
from data.DIEMHP hu
join Data.DMHOCPHAN dm
on dm.MaHP= hu.MaHP
where hu.MaHp=001 --Đoạn này không dùng 'ToanCaoCapA1' do bị lỗi phông
)
select *,
	ROW_NUMBER() over(order by DiemHp desc) as [Row_number],
	rank() over (order by DiemHp desc) as [Rank]
from CTE

--29.Liệt kê tên các sinh viên thuộc ngành Tin Học Ứng Dụng có địa chỉ tại Quy Nhơn

select MaSv, hu.MaLop, TenNganh, DiaChi
from human.SINHVIEN hu
join common.DMLOP c
on c.MaLop=hu.MaLop
join common.DMNGANH N
on N.MaNganh=N.MaNganh
where n.MaNganh=480202 and hu.DiaChi like 'Q%' 

--30.Liệt kê tên các sinh viên trong lớp CT12 thuộc khoa Tin Học Ứng Dụng và có điểm trung bình môn học Tiếng Anh 1 trên 5
select hu.MaSv, HoTen, hp.MaHp, TenHp, DiemHp
from data.DIEMHP hp 
join human.SINHVIEN hu
on hu.MaSv = Hp.MaSV
join data.DMHOCPHAN Hph
on Hph.MaHP= hp.MaHP
where hp.MaHp=002 and DiemHp>5

--31.Liệt kê điểm số của các sinh viên cho môn học Vật lí đại cương sử dụng PIVOT 



--32. Liệt kê các sinh viên có điểm trung bình cao nhất cho tất cả các môn học sử dụng PIVOT

select 
	[1],
	[2],
	[3],
	
	HoTen
	
	
	

from
	(select hu.MaSv, HoTen, hp.MaHp, TenHp, DiemHp
	from data.DIEMHP hp 
	join human.SINHVIEN hu
	on hu.MaSv = Hp.MaSV
	join data.DMHOCPHAN Hph
	on Hph.MaHP= hp.MaHP) as PVS
	
pivot (max(DiemHp) for MaHp in ([1],
								[2],
								[3])) as PVT


---Em cố làm theo Pivot nma không ra nên làm theo CTE
with CTE as (
select hu.MaSv, HoTen, hp.MaHp, TenHp, DiemHp
	from data.DIEMHP hp 
	join human.SINHVIEN hu
	on hu.MaSv = Hp.MaSV
	join data.DMHOCPHAN Hph
	on Hph.MaHP= hp.MaHP
),
CTE2 as(
select *,
		rank() over (partition by TenHp order by DiemHp desc) as [Rank]
from CTE),
CTE3 as(
	select * 
	from CTE2
	where [Rank]=1)
select HoTen, TenHp, DiemHp, [Rank] from CTE3
