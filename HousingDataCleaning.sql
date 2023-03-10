/* Data Cleaning */

select *
from dbo.Housing

-------------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format

select SaleDate, convert(date, SaleDate)
from dbo.Housing


Alter Table dbo.Housing
Add SaleDate2 Date


update dbo.Housing
set SaleDate2 = convert(date, SaleDate)


select SaleDate, SaleDate2
from dbo.Housing


-------------------------------------------------------------------------------------------------------------------------------
-- Populate Missing Property Address Data

select *
from dbo.Housing
--where PropertyAddress is null
order by ParcelID


select h1.ParcelID, h1.PropertyAddress, h1.[UniqueID ], h2.ParcelID, h2.PropertyAddress, h2.[UniqueID ], Isnull(h1.PropertyAddress, h2.PropertyAddress)
from dbo.Housing as h1
join dbo.Housing as h2
	on h1.ParcelID = h2.ParcelID
	and h1.[UniqueID ] <> h2.[UniqueID ]
where h1.PropertyAddress is null


update h1
set PropertyAddress = Isnull(h1.PropertyAddress, h2.PropertyAddress)
from dbo.Housing as h1
join dbo.Housing as h2
	on h1.ParcelID = h2.ParcelID
	and h1.[UniqueID ] <> h2.[UniqueID ]
where h1.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------------
-- Separating PropertyAddress into different Columns (Address, City)

select PropertyAddress
from dbo.Housing


select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as NewAddress,
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as City
from dbo.Housing


Alter Table dbo.Housing
Add PropertyAddress2 nvarchar(255)


update dbo.Housing
set PropertyAddress2 = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter Table dbo.Housing
Add PropertyCity2 nvarchar(255)


update dbo.Housing
set PropertyCity2 = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) 

select *
from dbo.Housing

-------------------------------------------------------------------------------------------------------------------------------
-- Remove extra whitespace between inside string of PropertyAddress2

select PropertyAddress2
from dbo.Housing

select PropertyAddress2, replace(replace(replace(PropertyAddress2, '  ', '<>'), '><', ''), '<>', ' ')
from dbo.Housing

select PropertyAddress2,
		case
			when PropertyAddress2 like '%  %' then replace(replace(replace(PropertyAddress2, '  ', '<>'), '><', ''), '<>', ' ')
			else PropertyAddress2
			end as trim_address
from dbo.Housing

update dbo.Housing
set PropertyAddress2 = case
				when PropertyAddress2 like '%  %' then replace(replace(replace(PropertyAddress2, '  ', '<>'), '><', ''), '<>', ' ')
				else PropertyAddress2
				end

select *
from dbo.Housing

-------------------------------------------------------------------------------------------------------------------------------
-- Separate Owner Address into different columns (Address, City, State)

select OwnerAddress
from dbo.Housing

select PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3), 
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from dbo.Housing


Alter Table dbo.Housing
Add OwnerAddress2 nvarchar(255)


update dbo.Housing
set OwnerAddress2 = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


Alter Table dbo.Housing
Add OwnerCity nvarchar(255)


update dbo.Housing
set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


Alter Table dbo.Housing
Add OwnerState nvarchar(255)


update dbo.Housing
set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 


select *
from dbo.Housing

-------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N Values to Yes and No in the 'Sold as Vacant' Column

select distinct(SoldAsVacant), count(SoldAsVacant) as 'count_sold'
from dbo.Housing
group by SoldAsVacant
order by count_sold


select SoldAsVacant,
		case 
			when SoldAsVacant = 'Y' then 'Yes'
			when SoldAsVacant = 'N' then 'No'
			else SoldAsVacant
			end 
from dbo.Housing

update dbo.Housing
set SoldAsVacant = case 
			when SoldAsVacant = 'Y' then 'Yes'
			when SoldAsVacant = 'N' then 'No'
			else SoldAsVacant
			end 


-------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

with RowNumberCTE as (

select *,
	row_number() over (partition by ParcelID,
									PropertyAddress,
									SaleDate,
									SalePrice,
									LegalReference
									order by
										UniqueID) as row_num
from dbo.Housing
)
select *
from RowNumberCTE
where row_num > 1

-- Used with CTE to delete duplicates identified by the row number
--delete
--from RowNumberCTE
--where row_num > 1



-------------------------------------------------------------------------------------------------------------------------------
-- Remove Unused Columns

select *
from dbo.Housing


Alter Table dbo.Housing
Drop Column PropertyAddress, OwnerAddress, SaleDate
